//
//  MZMZWidzetLiveActivity.swift
//  MZMZWidzet
//
//  Created by 강준영 on 2025/04/16.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MZMZWidzetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MZMZWidzetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MZMZWidzetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MZMZWidzetAttributes {
    fileprivate static var preview: MZMZWidzetAttributes {
        MZMZWidzetAttributes(name: "World")
    }
}

extension MZMZWidzetAttributes.ContentState {
    fileprivate static var smiley: MZMZWidzetAttributes.ContentState {
        MZMZWidzetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MZMZWidzetAttributes.ContentState {
         MZMZWidzetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MZMZWidzetAttributes.preview) {
   MZMZWidzetLiveActivity()
} contentStates: {
    MZMZWidzetAttributes.ContentState.smiley
    MZMZWidzetAttributes.ContentState.starEyes
}
