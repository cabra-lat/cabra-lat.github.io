const { BskyAgent } = require('@atproto/api')

async function postToBluesky(url, title) {
  const agent = new BskyAgent({
    service: 'https://bsky.social',
  })

  await agent.login({
    identifier: process.env.BLSKY_IDENTIFIER,
    password: process.env.BLSKY_APP_PASSWORD,
  })


  const postText = `🔥 Nova postagem: ${title}\n\n${url}`
  
  const { uri } = await agent.post({
    text: postText,
  })

  console.log(`Post publicado com sucesso! URI: ${uri}`)
}

if (process.argv.length !== 4) {
  console.error('Uso: node bluesky_post.js <url_da_postagem> <titulo_da_postagem>')
  process.exit(1)
}

if (!process.env.BLSKY_IDENTIFIER || !process.env.BLSKY_APP_PASSWORD) {
  console.error('ERRO: Credenciais do Bluesky não configuradas!');
  process.exit(1);
}

const url = process.argv[2]
const title = process.argv[3]
postToBluesky(url, title).catch(console.error)
