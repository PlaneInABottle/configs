// create-upload-token Edge Function
// Generates a signed upload URL so clients can upload files without exposing
// the service role key. Deploy with:
//   supabase functions deploy create-upload-token --no-verify-jwt
//
// Client then uses the returned token in the x-signature header for TUS uploads.

import { createClient } from 'npm:@supabase/supabase-js'

const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
)

Deno.serve(async (req) => {
  // ── Auth check ───────────────────────────────────────────────────────
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // Verify the user is authenticated via Supabase Auth
  const token = authHeader.replace('Bearer ', '')
  const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token)

  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // ── Parse request ────────────────────────────────────────────────────
  let filename: string
  try {
    const body = await req.json()
    filename = body.filename
    if (!filename) throw new Error('filename required')
  } catch {
    return new Response(JSON.stringify({ error: 'Invalid JSON body, "filename" required' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // ── Generate signed upload URL ───────────────────────────────────────
  // Namespace files by user to prevent overwriting others' files
  const filePath = `${user.id}/${filename}`

  const { data, error } = await supabaseAdmin.storage
    .from('uploads')
    .createSignedUploadUrl(filePath, { upsert: true })

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }

  // ── Return token ─────────────────────────────────────────────────────
  return new Response(JSON.stringify({
    token: data.token,
    path: filePath,
    signedUrl: data.signedUrl,
  }), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  })
})
