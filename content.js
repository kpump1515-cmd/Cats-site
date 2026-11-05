import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
const sb = createClient('https://dojnpcaehdyxtlmmeiff.supabase.co','sb_publishable_2vb4cfQllwG-bfBJDYUqXg_oAh1AWVk');
const page = (location.pathname.split('/').pop() || 'index.html').replace(/\.html$/,'') || 'index';
const { data, error } = await sb.from('site_content').select('key,value').eq('page', page);
if (!error && data) {
  for (const row of data) {
    if (row.key.startsWith('i')) {
      document.querySelectorAll(`[data-edit-img="${row.key}"]`).forEach(img => {
        img.src = row.value;
        const a = img.closest('a'); if (a && /\.(jpe?g|png|webp)$/i.test(a.getAttribute('href') || '')) a.href = row.value;
      });
    } else {
      document.querySelectorAll(`[data-edit="${row.key}"]`).forEach(el => { el.textContent = row.value; });
    }
  }
}
