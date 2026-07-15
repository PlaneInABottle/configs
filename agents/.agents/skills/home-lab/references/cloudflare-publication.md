# Cloudflare Publication, DNS, and R2

**Related**: [Home Lab Skill](../SKILL.md)

## Contents

- [Choose the correct interface](#choose-the-correct-interface)
- [Preflight and authorization](#preflight-and-authorization)
- [Move authoritative DNS safely](#move-authoritative-dns-safely)
- [Create a stable named Tunnel](#create-a-stable-named-tunnel)
- [Run the connector at boot](#run-the-connector-at-boot)
- [Automate DNS safely](#automate-dns-safely)
- [Configure R2](#configure-r2)
- [Verify and troubleshoot](#verify-and-troubleshoot)
- [Security and recovery boundaries](#security-and-recovery-boundaries)

## Choose the correct interface

Cloudflare does not have one CLI for every product:

| Interface | Use it for | Do not assume it handles |
| --- | --- | --- |
| `cloudflared` | Tunnel login, named Tunnel creation, ingress routing, connector service, and Tunnel DNS routes | General DNS-zone administration or R2 |
| Wrangler | Workers and developer-platform products, including basic R2 bucket/object operations | Registrar changes or general DNS administration |
| Cloudflare REST API | Scoped one-off automation across supported account and zone resources | Declarative state or automatic rollback |
| Cloudflare Terraform provider | Repeatable, reviewable DNS and Cloudflare infrastructure | Registrar-side nameserver changes unless the registrar is also managed |

Prefer dashboard/browser authorization for an interactive one-time setup, a narrowly scoped API token for automation, and Terraform when Cloudflare configuration should be versioned and reproduced. Pin Wrangler and Terraform provider versions in automation; an interactive `npx wrangler@latest` check is not a reproducible deployment dependency.

## Preflight and authorization

1. Confirm who owns the domain, which registrar holds it, and which provider is currently authoritative for DNS.
2. Export or record all existing DNS entries before changing nameservers. Preserve MX, SPF, DKIM, DMARC, provider-verification, and application records.
3. Record the current public application health and DNS answers so rollback has a known target.
4. Verify the origin application responds on loopback before involving Cloudflare.
5. Install `cloudflared` from Cloudflare's current signed package repository or reviewed release package for the host OS and architecture. Do not hard-code an ARM or x86 binary URL for every server.
6. Use separate, least-privilege credentials for DNS automation, Tunnel execution, and R2 application access.

Never paste tokens into chat, commit them, print the environment, or retain them in shell history. Keep credential files outside repositories with restrictive permissions.

## Move authoritative DNS safely

Adding a domain to Cloudflare and changing its authoritative nameservers are separate from creating host/glue records at the registrar. Do not put Cloudflare-assigned nameservers into a registrar's **Nameserver Registration**, **Register Nameserver**, or **Host Records** screen; those screens create glue for nameservers you operate yourself.

Use this migration order:

1. Add the zone to Cloudflare and review the imported records against the saved inventory.
2. Recreate missing email and verification records before delegation.
3. At the registrar, replace the domain's authoritative nameservers with the pair assigned by Cloudflare.
4. Wait until public resolvers report the Cloudflare nameservers.
5. Verify email DNS and existing sites before changing application records.
6. Create the new Tunnel hostname and test it.
7. Remove obsolete hosting records only after the replacement is healthy and rollback is no longer needed.

Useful read-only checks:

```bash
dig +short NS example.com
dig +short CNAME app.example.com
dig +short MX example.com
curl --fail --silent --show-error https://app.example.com/health
```

DNS proxying obscures the origin address from ordinary DNS responses; it does not erase an address already published in historical DNS, email headers, other records, or third-party datasets.

## Create a stable named Tunnel

Use a named Tunnel for a stable hostname. Quick/TryCloudflare URLs are useful for temporary previews, not production routing.

For a locally managed Tunnel:

```bash
cloudflared --version
cloudflared tunnel login
cloudflared tunnel create <tunnel-name>
cloudflared tunnel list
```

`cloudflared tunnel login` opens browser authorization and creates `cert.pem`. Treat that file as an account-wide management credential: it can manage multiple Tunnels and DNS routes. Creating a Tunnel also creates `<TUNNEL-UUID>.json`, which is limited to running that Tunnel. The server service should receive only the Tunnel-specific credential whenever possible; it normally does not need `cert.pem`.

Example locally managed configuration:

```yaml
tunnel: <TUNNEL-UUID>
credentials-file: /etc/cloudflared/<TUNNEL-UUID>.json

ingress:
  - hostname: app.example.com
    service: http://127.0.0.1:3000
  - service: http_status:404
```

Validate routing before installing the service:

```bash
cloudflared tunnel --config /path/to/config.yml ingress validate
cloudflared tunnel --config /path/to/config.yml ingress rule https://app.example.com
cloudflared tunnel route dns <TUNNEL-UUID-or-name> app.example.com
cloudflared tunnel info <TUNNEL-UUID-or-name>
```

The `route dns` command creates a CNAME to `<TUNNEL-UUID>.cfargotunnel.com` and requires the management certificate for a locally managed Tunnel. The DNS record and running connector are independent: stopping the Tunnel does not remove DNS.

For a remotely managed Tunnel, create it in the Cloudflare dashboard or API and install the connector with the Tunnel token provided by Cloudflare. Do not combine local credential-file and remote-token instructions accidentally.

## Run the connector at boot

On Linux, install `cloudflared` as a systemd service after the named Tunnel and configuration are ready. When using `sudo`, pass an explicit configuration path because root's home differs from the operator's home:

```bash
sudo cloudflared --config /etc/cloudflared/config.yml service install
sudo systemctl enable --now cloudflared
systemctl status cloudflared --no-pager
```

Before installation, copy only the required Tunnel credential and reviewed configuration into `/etc/cloudflared`, owned by root and unreadable to unrelated users. Do not copy `cert.pem` there merely to run the Tunnel.

After configuration changes:

```bash
sudo systemctl restart cloudflared
systemctl is-active cloudflared
journalctl -u cloudflared --since "10 minutes ago" --no-pager
```

Use one system service per host and add multiple ingress routes to that Tunnel unless isolation requirements justify a different supervised layout. Verify controlled reboot recovery; an active connector does not prove the origin application is ready.

## Automate DNS safely

Wrangler is not the default tool for arbitrary DNS record management. Use the Cloudflare REST API for narrow operations or the Terraform provider for durable infrastructure-as-code.

For API automation:

- Create an API token instead of using the Global API Key.
- Restrict it to the specific zone and minimum permission, such as Zone DNS Read or Edit.
- Add token expiry and source-IP restrictions when operationally practical.
- Supply it through a secret manager or ephemeral environment variable, never source code or command arguments that will be logged.
- Read and save the exact current record before mutation; update by record ID instead of creating duplicates.
- Re-query authoritative DNS and the application after every change.

Use Terraform when several records, routes, or environments must remain reproducible. Review `terraform plan`, protect the state because it can contain sensitive values, apply only the reviewed plan, and keep a tested rollback record.

## Configure R2

Wrangler can create and inspect R2 buckets interactively:

```bash
npx wrangler@latest login
npx wrangler@latest whoami
npx wrangler@latest r2 bucket list
npx wrangler@latest r2 bucket create <bucket-name>
```

For repository automation, install and pin Wrangler in the project instead of relying on `@latest`.

Wrangler browser login authorizes Wrangler; it does not create the S3-compatible access keys an application needs. For an S3-compatible application:

1. Create a bucket, which is private by default.
2. Create an R2 API credential restricted to the intended bucket and required read/write scope.
3. Store the Access Key ID and Secret Access Key in the deployment secret store.
4. Configure the application with the R2 S3 endpoint, region `auto`, bucket, and credentials according to its storage adapter.
5. Upload, read, and delete a disposable object through the same application path used in production.
6. Confirm private objects are not anonymously accessible and that signed URLs or authenticated proxying work as designed.

Do not make a bucket public merely to solve an application credential or CORS problem. Object storage durability is not a complete backup policy; define retention, accidental-deletion recovery, and an independent backup or replication path according to the data risk.

## Verify and troubleshoot

Check each boundary independently:

1. Origin: `curl` the loopback health endpoint on the server.
2. Connector: verify the systemd service and bounded recent logs.
3. Tunnel: inspect Tunnel health and ingress-rule selection.
4. DNS: confirm authoritative nameservers and the expected CNAME/proxy state.
5. Edge: request the final HTTPS hostname from a different network.
6. Application: test login, background workers, uploads, WebSockets, and outbound integrations that the demo requires.
7. Recovery: reboot once under control and repeat the checks.

Common distinctions:

- A healthy Tunnel with an HTTP 502 usually means `cloudflared` cannot reach the configured origin.
- Cloudflare error 1016 after a connector stops can occur because its DNS route still exists.
- A local health response does not prove public DNS, TLS, or the Tunnel works.
- A public page response does not prove workers, queues, database persistence, uploads, or reboot recovery work.
- Cloudflare Tunnel normally needs outbound connectivity, not inbound router forwarding for ports 80/443. Keep the host firewall default-deny inbound unless another reviewed service requires a narrow rule.

## Security and recovery boundaries

- A Tunnel reduces inbound exposure but does not replace application authentication, authorization, patching, rate limiting, backups, or host firewalling.
- Never publish database, Redis, Docker, supervisor, metrics, admin, or SSH interfaces through a public hostname. Put administration behind a private VPN or identity-aware access policy.
- Keep origins on `127.0.0.1` when the connector is on the same host. If a container network is used, expose only the minimum internal path.
- Record which credential can manage the account, run one Tunnel, edit one DNS zone, or access one bucket. Rotate the smallest credential after suspected exposure.
- Preserve an exact DNS rollback target and keep the old provider available until the new path is verified.
- During diagnosis, show credential file paths, ownership, scope, and redacted identifiers—not credential contents or full process environments.
