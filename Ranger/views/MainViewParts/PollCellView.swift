//
//  PollCellView.swift
//  Ranger
//
//  Created by Vlad Kyrylenko on 08.04.2024.
//

import SwiftUI

struct PollCellView: View {
    @State var poll: PollModel
    
    var body: some View {
        HStack{
            VStack{
                Spacer()
                HStack {
                    Text(poll.name)
                    Spacer()
                }
                HStack {
                    Text(poll.id)
                        .foregroundStyle(.gray)
                        .opacity(0.3)
                        .font(.system(size: 18))
                    Spacer()
                }
                
                Spacer()
            }
            
            Spacer()
            
            if poll.isClosed {
                Image(systemName: "lock")
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    PollCellView(poll: PollModel(id: "someid", creatorId: "somecreatorId", name: "Test", isClosed: false, password: "", alternatives: ["alt1","alt2","alt3","alt4","alt5"], statistics: [], experts: [], gradationMin: "min", gradationMax: "max"))
}
