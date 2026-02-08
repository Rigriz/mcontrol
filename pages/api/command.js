import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { system } = req.query

  const { data } = await supabase
    .from('systems')
    .select('command')
    .eq('system', system)
    .single()

  res.json({
    command: data?.command || "stop"
  })
}
