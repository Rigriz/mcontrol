import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { data, error } = await supabase
    .from('mi')
    .select('*')
    .order('last_seen', { ascending: false })

  res.json(data || [])
}
