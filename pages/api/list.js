import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { data } = await supabase
    .from('mi')
    .select('*')

  res.json(data || [])
}
