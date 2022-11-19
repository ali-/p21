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
	@State var dealer: [Card] = [Card(.diamond, 12), Card(.club, 1)]
	@State var hand: [Card] = []
	@State var deck = Card.deck()
	var body: some View {
		VStack {
			Text("Your Hand")
			HStack {
				ForEach(hand, id: \.id) { card in
					VStack {
						Text("\(card.character)\n\(card.suit.symbol)")
							.font(.system(size: 15).monospaced())
							.padding(3)
					}
					.background(Color.white)
					.cornerRadius(3)
					.foregroundColor(card.suit.color)
				}
			}
			.frame(maxHeight: .infinity, alignment: .top)
			.padding()
			HStack {
				// TODO: Offer split if pair
				Button("Hit") {
					hand.append(deck.popLast()!)
					let card = hand[hand.count-1]
					print("Player drew \(card.suit.symbol)\(card.character)")
				}
				Button("Stay") {
					print("Draw dealer cards")
					// Hide buttons
					// Draw dealer cards
				}
			}
			.frame(maxHeight: .infinity, alignment: .bottom)
		}
		.frame(maxHeight: .infinity, alignment: .top)
	}
}
