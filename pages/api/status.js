import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
)

export default async function handler(req, res) {

  if (req.method !== "POST") {
    return res.status(405).end()
  }

  const { system, vpn, mining } = req.body

  await supabase
    .from('systems')
    .upsert({
      id: system,
      vpn: vpn,
      mining: mining,
      last_seen: new Date()
    })

  res.json({ ok: true })
}