import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
const supabase = createClient('https://gqubhatlrjfcxrrywsjr.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.x')
const { error } = await supabase.auth.getUser('invalid')
console.log(JSON.stringify(error))
