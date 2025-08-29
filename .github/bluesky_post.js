const { BskyAgent, RichText } = require('@atproto/api')

async function postToBluesky(url, title) {
  // Validação básica
  if (!url || !title) {
    console.error('Erro: URL ou título não fornecidos')
    process.exit(1)
  }
  
  // Limpeza da URL
  const cleanUrl = url.trim().replace(/\s+/g, '');
  
  console.log(`Tentando postar: "${title}" para ${cleanUrl}`);
  
  // Verificar se as credenciais estão definidas
  if (!process.env.BLSKY_IDENTIFIER || !process.env.BLSKY_APP_PASSWORD) {
    console.error('ERRO: Credenciais do Bluesky não configuradas!');
    console.error('Verifique se os segredos BLSKY_IDENTIFIER e BLSKY_APP_PASSWORD estão configurados no repositório');
    process.exit(1);
  }
  
  const agent = new BskyAgent({
    service: 'https://bsky.social',
  })

  try {
    await agent.login({
      identifier: process.env.BLSKY_IDENTIFIER,
      password: process.env.BLSKY_APP_PASSWORD,
    })

    // Cria o texto rico com facets para o link
    const rt = new RichText({ text: `🔥 Nova postagem: ${title}\n\n${cleanUrl}` })
    await rt.detectFacets(agent) // Detecta automaticamente links e menções
    
    // Publica com facets
    const post = await agent.post({
      text: rt.text,
      facets: rt.facets,
      createdAt: new Date().toISOString(),
    })

    console.log(`Post publicado com sucesso! URI: ${post.uri}`)
  } catch (error) {
    console.error('Erro durante a autenticação ou postagem:', error)
    if (error.message.includes('Invalid identifier or password')) {
      console.error('Verifique se os segredos BLSKY_IDENTIFIER e BLSKY_APP_PASSWORD estão configurados corretamente no repositório')
    }
    process.exit(1)
  }
}

if (process.argv.length !== 4) {
  console.error('Uso: node bluesky_post.js <url_da_postagem> <titulo_da_postagem>')
  process.exit(1)
}

const url = process.argv[2]
const title = process.argv[3]
postToBluesky(url, title).catch(console.error)
