import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
)

export default async function handler(req, res) {

  if (req.method !== "POST") {
    return res.status(405).end()
  }

  const { system, command } = req.body

  await supabase
    .from('systems')
    .update({ command })
    .eq('id', system)

  res.json({ ok: true })
}
