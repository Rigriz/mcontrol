import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { id, command } = req.body

  await supabase
    .from('mi')
    .update({ command })
    .eq('id', id)

  res.json({ ok: true })
}
