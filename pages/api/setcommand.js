import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { system, command } = req.body

  await supabase
    .from('systems')
    .update({ command })
    .eq('system', system)

  res.json({ ok: true })
}
