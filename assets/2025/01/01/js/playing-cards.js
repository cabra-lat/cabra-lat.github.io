const { CardsJS } = await import('https://cdn.jsdelivr.net/gh/cabra-lat/cards.js@0.3.0/src/cards.min.js')

let cards = new CardsJS({ cardsUrl: 'https://blog.cabra.su/cards.js/img/cards.png' });

let deck = cards.Deck();
deck.addCards(cards.all);

let gameOver = false;
let pile;
let isPlayersTurn = true; // Controle de turnos adicionado

let yours = cards.Deck({
  type: 'hand',
  label: 'Your Hand',
  sticky: 'bottom',
  faceUp: true,
  y: cards.playableArea.bottom
});

let theirs = cards.Deck({
  type: 'hand',
  sticky: 'bottom',
  label: 'AI Opponent',
  y: cards.playableArea.top
});

yours.on('mouseenter', card => {
  if (isPlayersTurn && !gameOver) {
    canDiscard(card)
      ? yours.label.text = `You can play ${card}`
      : yours.label.text = `Can't play ${card}!`;
  }
});
theirs.on('mouseenter', _ => theirs.label.text = 'AI Opponent');
deck.on('mouseenter', _ => {
  if (!gameOver && pile) {
    if (isPlayersTurn) {
      const ableToPlay = yours.filter(canDiscard).length > 0;
      deck.label.text = ableToPlay ? 'Main Deck\n(Able to play)' : 'Main Deck\n(No plays, draw card)';
    } else {
      deck.label.text = `Main Deck\n(AI's turn)`;
    }
  }
});

theirs.on('mouseleave', _ => theirs.label.text = 'AI Opponent')
deck.on('mouseleave', _ => { 
  if (!gameOver) {
    if (isPlayersTurn) deck.label.text = 'Main Deck';
    else deck.label.text = "Main Deck\n(AI's turn)";
  }
})
yours.on('mouseleave', _ => {
  if (isPlayersTurn && !gameOver) {
    yours.label.text = "Your Hand";
  }
})

deck.label.sticky = 'left'

theirs.trigger('mouseleave')
deck.trigger('mouseleave')
yours.trigger('mouseleave')

let canPlay = (card, top) => {
  return card.suitIndex === top?.suitIndex ||
         card.rankIndex === top?.rankIndex;
};

deck.x -= 50;
deck.render();

deck.shuffle()

pile = cards.Deck({
  label: 'discard',
  sticky: 'right',
  faceUp: true
});

pile.on('mouseenter', _ => pile.label.text = `discard: ${pile.length}`)
pile.on('mouseleave', _ => pile.label.text = `discard`)

pile.x += 50;
pile.addCard(deck.topCard());
pile.render();

let canDiscard = card => canPlay(card, pile.topCard())

// Função de IA do oponente
function aiTurn() {
  if (gameOver) return;
  
  const topCard = pile.topCard();
  const playable = theirs.filter(card => canPlay(card, topCard));
  
  // Estratégia da IA: prioriza cartas com menos repetições na mão
  // Isso evita que a IA fique presa com muitas cartas do mesmo valor [[3]]
  if (playable.length > 0) {
    const strategicCard = playable.sort((a, b) => {
      const countA = theirs.filter(c => c.rankIndex === a.rankIndex).length;
      const countB = theirs.filter(c => c.rankIndex === b.rankIndex).length;
      return countA - countB; // Menos repetições = prioridade maior
    })[0];

    theirs.removeCard(strategicCard);
    pile.addCard(strategicCard);
    pile.render();
    
    // Verifica se a IA venceu
    if (theirs.length === 0) {
      gameOver = true;
      deck.label.text = `💀 You Lost!\nAI emptied their hand.\nClick deck to restart.`;
      theirs.faceUp = true;
      return;
    }
  } 
  // IA não pode jogar → compra carta
  else if (deck.length > 0) {
    deck.deal(1, [theirs]);
  } 
  // IA perde (sem cartas jogáveis + baralho vazio)
  else {
    gameOver = true;
    deck.label.text = `🏆 You Won!\nAI couldn't play.\nClick deck to restart.`;
    theirs.faceUp = true;
    return;
  }

  // Volta para a vez do jogador
  isPlayersTurn = true;
  deck.label.text = "Main Deck\n(Your turn!)";
}

// restart function
let restartGame = async () => {
  await yours.deal(-1, [deck]);
  await theirs.deal(-1, [deck]);
  await pile.deal(-1, [deck]);

  deck.shuffle();

  await deck.deal(5, [yours, theirs]);

  pile.addCard(deck.topCard());
  pile.render();

  gameOver = false;
  isPlayersTurn = true; // Resetar controle de turnos
  deck.label.text = "Main Deck\n(Your turn!)";
  theirs.faceUp = false;
};

// deck click
deck.click(async (card) => {
  if (gameOver) {
    await restartGame();
    return;
  }
  
  if (!isPlayersTurn) return;
  
  const playable = yours.filter(canDiscard);
  if (playable.length === 0 && card === deck.topCard()) {
    await deck.deal(1, [yours]);
    
    // Verifica se após comprar ainda não pode jogar
    if (yours.filter(canDiscard).length === 0 && deck.length === 0) {
      gameOver = true;
      deck.label.text = `💀 You Lost!\nNo more cards to draw.\nClick deck to restart.`;
      theirs.faceUp = true;
      return;
    }
    
    isPlayersTurn = false;
    deck.label.text = "Main Deck\n(🤖 AI's turn...)";
    setTimeout(aiTurn, 1000); // Delay para simular "pensamento" da IA
    return;
  }
  
  deck.label.text = 'Able to play \n No more draws!';
});

yours.click((card) => {
  if (gameOver || !isPlayersTurn) return;
  
  const playable = yours.filter(canDiscard);
  if (playable.includes(card)) {
    pile.addCard(card);
    yours.label.text = `Played ${card}.`;
    
    // Verifica se o jogador venceu
    if (yours.length === 0) {
      gameOver = true;
      deck.label.text = `🏆 You Won!\nScore: ${pile.length} cards\nClick deck to restart.`;
      theirs.faceUp = true;
      return;
    }
    
    isPlayersTurn = false;
    deck.label.text = "Main Deck\n(🤖 AI's turn...)";
    setTimeout(aiTurn, 1000);
  } else {
    yours.label.text = `Can't play ${card}!`;
  }
})

// Inicialização do jogo
await deck.deal(5, [yours, theirs]);
isPlayersTurn = true;
deck.label.text = "Main Deck\n(Your turn!)";

window.status = 'say_cheese'
