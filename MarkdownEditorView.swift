import SwiftUI

struct MarkdownEditorView: View {
    @State private var markdownText: String = ""
    let fileName: String?
    let onDismiss: () -> Void // 关闭编辑器回调
    
    @State private var showSaveAlert: Bool = false
    @State private var isPreviewing: Bool = false // 控制是否展示预览界面
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $markdownText)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                // 按钮组
                HStack {
                    Button(action: { onDismiss() }) {
                        Text("返回")
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: { isPreviewing = true }) {
                        Text("预览")
                    }
                    .padding()
                    
                    Button(action: saveFile) {
                        Text("保存")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle(fileName ?? "新建文件")
            .navigationBarHidden(true)
            .onAppear(perform: loadFile)
            .alert("保存成功", isPresented: $showSaveAlert) {
                Button("确定", role: .cancel) {}
            }
            .sheet(isPresented: $isPreviewing) {
                MarkdownPreviewView(markdownText: markdownText, onDismiss: {
                    isPreviewing = false
                })
            }
        }
    }
    
    // 加载文件内容
    func loadFile() {
        guard let fileName = fileName else { return }
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
                markdownText = content
            }
        }
    }
    
    // 保存文件
    func saveFile() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let newFileName = fileName ?? "\(UUID().uuidString).md"
            let fileURL = documentsURL.appendingPathComponent(newFileName)
            do {
                try markdownText.write(to: fileURL, atomically: true, encoding: .utf8)
                showSaveAlert = true
            } catch {
                print("无法保存文件：\(error.localizedDescription)")
            }
        }
    }
}
