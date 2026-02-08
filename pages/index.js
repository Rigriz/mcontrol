import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  const { id, mining, cpu, vpn } = req.body

  await supabase
    .from('mi')
    .update({
      mining,
      cpu,
      vpn,
      last_seen: new Date()
    })
    .eq('id', id)

  res.json({ ok: true })
}
