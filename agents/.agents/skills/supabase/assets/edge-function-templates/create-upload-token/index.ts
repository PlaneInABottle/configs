import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Headers': 'authorization, content-type, x-client-info, apikey',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Origin': '*',
};

function json(body: unknown, status: number): Response {
  return Response.json(body, { status, headers: corsHeaders });
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const authHeader = req.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) return json({ error: 'Unauthorized' }, 401);

  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );
  const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(
    authHeader.slice('Bearer '.length),
  );
  if (userError || !user) return json({ error: 'Unauthorized' }, 401);

  let filename: string;
  try {
    const body = await req.json();
    filename = String(body.filename ?? '');
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }

  if (!/^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$/.test(filename)) {
    return json({ error: 'Invalid filename' }, 400);
  }

  const path = `${user.id}/${crypto.randomUUID()}-${filename}`;
  const { data, error } = await supabaseAdmin.storage
    .from('uploads')
    .createSignedUploadUrl(path);

  if (error) return json({ error: 'Could not create upload URL' }, 500);
  return json({ path, token: data.token }, 200);
});
