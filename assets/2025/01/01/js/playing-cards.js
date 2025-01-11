const { CardsJS } = await import('https://cdn.jsdelivr.net/gh/cabra-lat/cards.js@0.3.0/src/cards.min.js')

let cards = new CardsJS({ cardsUrl: 'https://blog.cabra.lat/cards.js/img/cards.png' });
let deck = cards.Deck();
deck.addCards(cards.all);

let yours = cards.Deck({
  type: 'hand',                // Type: 'hand' indicates it will be rendered as a hand
  label: 'Your Hand',          // Label for the hand
  faceUp: true,
  y: cards.playableArea.bottom // Position at the bottom of the playable area
});

let theirs = cards.Deck({
  type: 'hand',
  label: 'Other Hand',
  y: cards.playableArea.top  // Position at the top of the playable area
});

yours.on('mouseenter',
   card => yours.label.text = `This is ${card}`);
theirs.on('mouseenter',
   card => theirs.label.text = 'Other Hand');
deck.on('mouseenter',
   card => deck.label.text = 'Main Deck');

theirs.on('mouseleave',
  card => theirs.label.text = '')
deck.on('mouseleave',
  card => deck.label.text = '')
yours.on('mouseleave',
  card => yours.label.text = '')

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

await deck.deal(5, [yours, theirs])

let pile = cards.Deck({
  label: 'discard',
  sticky: 'top',
  faceUp: true
});

pile.x += 50;
pile.addCard(deck.topCard());
pile.render();

let canDiscard = card => canPlay(card, pile.topCard())

// Handle mouse enter event to show playable cards
yours.on('mouseenter', card => {
  canDiscard(card)
    ? yours.label.text = `You can play ${card}`
    : yours.label.text = `This is ${card}`;
});

// Handle deck click to draw cards
let gameOver = false;
deck.click(card => {
  if (gameOver) return;
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
    const gameWon = yours.length === 0
    const gameLost = !playable && deck.length === 0
    if (gameWon)  alert('You Won!')
    if (gameLost) alert('You Lost!')
    gameOver = gameWon || gameLost
    return
  }
  yours.label.text = `Can't play ${card}!`
})

pile.click( _ => {
    if (!gameOver) return
    yours
    .deal(-1, [ deck ])
    .then(_ => theirs.deal(-1, [ deck ]) )
    .then(_ => pile.deal(-1, [ deck ]) )
    .then(_ => deck.x += 50 )
})
