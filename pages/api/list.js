import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
)

export default async function handler(req, res) {

  const { data } = await supabase
    .from('systems')
    .select('*')

  res.json(data)
}