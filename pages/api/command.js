import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { id } = req.query

  const { data, error } = await supabase
    .from('mi')       // table name
    .select('command')
    .eq('id', id)     // column name
    .single()

  if (error || !data) {
    return res.json({ command: "stop" })
  }

  res.json({
    command: data.command
  })
}
