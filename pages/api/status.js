import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { id, running, cpu, vpn } = req.body

  const { data, error } = await supabase
    .from('mi')
    .upsert({
      id,
      running,
      cpu,
      vpn,
      last_seen: new Date()
    })

  if (error) {
    console.error("SUPABASE ERROR:", error)
    return res.status(500).json({ error: error.message })
  }

  res.json({ ok: true })
}
