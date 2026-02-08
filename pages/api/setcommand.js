import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { mi } = req.query

  const { data, error } = await supabase
    .from('mi')
    .select('command')
    .eq('id', mi)
    .single()

  if (error) {
    return res.json({ command: "stop" })
  }

  res.json({
    command: data?.command || "stop"
  })
}
