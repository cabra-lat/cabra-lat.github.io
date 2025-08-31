const { CardsJS } = await import('https://cdn.jsdelivr.net/gh/cabra-lat/cards.js@0.3.0/src/cards.min.js')

let cards = new CardsJS({ cardsUrl: 'https://blog.cabra.su/cards.js/img/cards.png' });

let deck = cards.Deck();
deck.addCards(cards.all);

let gameOver = false;
let pile;

let yours = cards.Deck({
  type: 'hand',
  label: 'Your Hand',
  faceUp: true,
  y: cards.playableArea.bottom
});

let theirs = cards.Deck({
  type: 'hand',
  label: 'Other Hand',
  y: cards.playableArea.top
});

yours.on('mouseenter', card => yours.label.text = `This is ${card}`);
theirs.on('mouseenter', _ => theirs.label.text = 'Other Hand');
deck.on('mouseenter', _ => {
  if (!gameOver && pile) deck.label.text = `Main Deck`;
});

theirs.on('mouseleave', _ => theirs.label.text = '')
deck.on('mouseleave', _ => { if (!gameOver) deck.label.text = '' })
yours.on('mouseleave', _ => yours.label.text = '')

deck.label.sticky = 'bottom'

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
  sticky: 'top',
  faceUp: true
});

pile.on('mouseenter', _ => pile.label.text = `discard: ${pile.length}`)
pile.on('mouseleave', _ => pile.label.text = `discard`)

pile.x += 50;
pile.addCard(deck.topCard());
pile.render();

let canDiscard = card => canPlay(card, pile.topCard())

// show playable card hint
yours.on('mouseenter', card => {
  canDiscard(card)
    ? yours.label.text = `You can play ${card}`
    : yours.label.text = `This is ${card}`;
});

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
  deck.label.text = `Main Deck`;
  theirs.faceUp = false;
};

// deck click
deck.click(async (card) => {
  if (gameOver) {
    await restartGame();
    return;
  }
  const ableToPlay = yours.filter(canDiscard).pop();
  if (!ableToPlay && card === deck.topCard()) {
    deck.deal(1, [yours]);
    return;
  }
  deck.label.text = 'Able to play \n No more draws!';
});

yours.click((card) => {
  const playable = yours.filter(canDiscard)
  if (playable.includes(card)) {
    pile.addCard(card)
    yours.label.text = `Played ${card}.`
  } else {
    yours.label.text = `Can't play ${card}!`
  }
  const gameWon = yours.length === 0
  const gameLost = playable.length === 0 && deck.length === 0

  if (gameWon) {
    deck.label.text = `🏆 You Won!\nScore: ${pile.length} cards\nClick deck to restart.`
  }
  if (gameLost) {
    deck.label.text = `💀 You Lost!\nScore: ${pile.length} cards\nClick deck to restart.`
  }
  gameOver = gameWon || gameLost
  if (gameOver) theirs.faceUp = true
})

await deck.deal(5, [yours, theirs])

window.status = 'say_cheese'

