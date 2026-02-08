import { supabase } from '../../lib/supabase'

export default async function handler(req, res) {

  const { data } = await supabase
    .from('systems')
    .select('*')
    .order('updated_at', { ascending: false })

  res.json(data)
}
