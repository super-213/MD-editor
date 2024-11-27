import SwiftUI
import MarkdownUI

struct MarkdownPreviewView: View {
    let markdownText: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                Markdown(markdownText)
                    .padding()
            }
            .navigationTitle("预览")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("返回", action: onDismiss))
        }
    }
}
