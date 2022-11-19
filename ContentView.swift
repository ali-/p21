//
//  ContentView.swift
//

import SwiftUI

enum Suit {
	case club, diamond, heart, spade
	var color: Color {
		switch (self) {
			case .diamond: return .red
			case .heart: return .red
			default: return .black
		}
	}
	var symbol: String {
		switch (self) {
			case .club: return "♣"
			case .diamond: return "♦"
			case .heart: return "♥"
			case .spade: return "♠"
		}
	}
}

class Card {
	let id = UUID()
	var suit: Suit
	var value: Int
	var character: String {
		switch (value) {
			case 1: return "A "
			case 10: return "10"
			case 11: return "J "
			case 12: return "Q "
			case 13: return "K "
			default: return "\(value) "
		}
	}
	init(_ suit: Suit, _ value: Int) {
		self.suit = suit
		self.value = value
	}
	static func points(_ cards: [Int]) -> Int {
		var aces = 0
		var points = 0
		for card in cards {
			// Add points counting aces as 11 by default
			if card == 1 { aces += 1; points += 11; }
			else if (card > 10) { points += 10 }
			else { points += card }
			// If points has exceeded 21 and player has aces, reduce to 1
			while points > 21 {
				if aces > 0 {
					aces -= 1
					points -= 10
				}
				else { break }
			}
		}
		return points
	}
	static func deck() -> [Card] {
		var cards: [Card] = []
		for i in 1...52 {
			var s = Suit.club
			if (i > 13 && i < 27) { s = Suit.diamond }
			else if (i > 26 && i < 40) { s = Suit.heart }
			else if (i > 39) { s = Suit.spade }
			let c = Card(s, i%13+1)
			cards.append(c)
		}
		cards.shuffle()
		return cards
	}
}

struct ContentView: View {
	@State var dealer: [Card] = []
	@State var hand: [Card] = []
	@State var deck = Card.deck()
	@State var outcome = 0
	@State var staying = false
	@State var label = "Stay"
	
	func initialize() {
		dealer.append(deck.popLast()!)
		dealer.append(deck.popLast()!)
		hand.append(deck.popLast()!)
		hand.append(deck.popLast()!)
	}
	
	func reset() {
		dealer = []
		hand = []
		deck = Card.deck()
		staying = false
		label = "Stay"
		initialize()
	}
	
	func getOutcome() -> Int {
		let dealerPoints = Card.points(dealer.map({$0.value}))
		let playerPoints = Card.points(hand.map({$0.value}))
		if playerPoints == dealerPoints { return 2 }
		else if playerPoints == 21 && dealerPoints != 21 { return 1 }
		else if playerPoints > dealerPoints && playerPoints < 21 { return 1 }
		else if playerPoints > 21 { return 0 }
		return 0
	}
	
	var body: some View {
		VStack {
			VStack {
				HStack {
					if staying {
						ForEach(dealer, id: \.id) { card in
							VStack {
								Text("\(card.character)\n\(card.suit.symbol)")
									.font(.system(size: 15).monospaced())
									.padding(3)
							}
							.background(.white)
							.cornerRadius(3)
							.foregroundColor(card.suit.color)
						}
					}
					else {
						// Only show one card
						if dealer.count > 0 {
							VStack {
								Text("\(dealer[0].character)\n\(dealer[0].suit.symbol)")
									.font(.system(size: 15).monospaced())
									.padding(3)
							}
							.background(.white)
							.cornerRadius(3)
							.foregroundColor(dealer[0].suit.color)
							VStack {
								Text("? \n ")
									.font(.system(size: 15).monospaced())
									.padding(3)
							}
							.background(.gray)
							.cornerRadius(3)
							.foregroundColor(.black)
						}
					}
				}
			}
			ZStack {
				if staying {
					switch outcome {
						case 1: Text("Winner!").fontWeight(.bold).foregroundColor(.green)
						case 2: Text("Push!").fontWeight(.bold).foregroundColor(.blue)
						default: Text("Loser!").fontWeight(.bold).foregroundColor(.red)
					}
				}
				else { Text("Your Turn").italic() }
			}
			VStack {
				HStack {
					ForEach(hand, id: \.id) { card in
						VStack {
							Text("\(card.character)\n\(card.suit.symbol)")
								.font(.system(size: 15).monospaced())
								.padding(3)
						}
						.background(.white)
						.cornerRadius(3)
						.foregroundColor(card.suit.color)
					}
				}
			}
			if !staying {
				HStack {
					// TODO: Offer split
					Button("Hit") {
						hand.append(deck.popLast()!)
						let playerPoints = Card.points(hand.map({$0.value}))
						if playerPoints > 21 {
							outcome = getOutcome()
							staying = true
						}
					}
					Button("\(label)") {
						outcome = getOutcome()
						staying = true
					}
				}
				.frame(maxHeight: .infinity, alignment: .bottom)
			}
			else {
				HStack {
					Button("Play Again") {
						reset()
					}
				}
				.frame(maxHeight: .infinity, alignment: .bottom)
			}
		}
		.frame(maxHeight: .infinity, alignment: .top)
		.onAppear(perform: initialize)
		.onTapGesture {
			if staying { reset() }
		}
	}
}
