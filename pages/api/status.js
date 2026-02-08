import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  if (req.method !== 'POST')
    return res.status(405).end()

  const { system, running, cpu, vpn } = req.body

  await supabase
    .from('systems')
    .upsert({
      system,
      running,
      cpu,
      vpn,
      updated_at: new Date()
    })

  res.json({ ok: true })
}
