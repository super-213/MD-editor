import SwiftUI

struct FileManagerView: View {
    @State private var files: [String] = [] // 保存文件名列表
    @State private var isEditing = false // 控制是否展示编辑器
    @State private var selectedFile: String? // 当前选择的文件名
    
    @State private var isRenaming = false // 控制是否展示重命名输入框
    @State private var renameFileName: String = "" // 重命名的文件名
    @State private var currentFileName: String = "" // 当前被重命名的文件名
    
    // 控制是否展示预览界面
    @State private var isPreviewing = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(files, id: \.self) { file in
                    HStack {
                        // 文件点击进入预览
                        Button(action: {
                            selectedFile = file
                            // 点击文件进入预览界面
                            showPreview(for: file)
                        }) {
                            Text(file)
                        }
                        .contextMenu {
                            // 长按显示重命名和编辑操作
                            Button(action: {
                                currentFileName = file
                                renameFileName = file
                                isRenaming = true
                            }) {
                                Text("重命名")
                                Image(systemName: "pencil")
                            }
                            
                            Button(action: {
                                selectedFile = file
                                isEditing = true
                            }) {
                                Text("编辑")
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                }
                .onDelete(perform: deleteFile)
            }
            .navigationTitle("文件管理")
            .toolbar {
                Button(action: {
                    selectedFile = nil
                    isEditing = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .onAppear(perform: loadFiles)
            .sheet(isPresented: $isEditing) {
                // 编辑页面
                MarkdownEditorView(fileName: selectedFile, onDismiss: {
                    loadFiles()
                    isEditing = false
                })
            }
            // 重命名输入框
            .alert("重命名文件", isPresented: $isRenaming) {
                VStack {
                    TextField("新文件名", text: $renameFileName)
                    Button("取消", role: .cancel) {}
                    Button("保存") {
                        renameFile()
                    }
                }
            }
            // 预览文件的 Sheet
            .sheet(isPresented: $isPreviewing) {
                if let selectedFile = selectedFile {
                    // 传递文件内容到预览界面
                    MarkdownPreviewView(markdownText: loadFileContent(fileName: selectedFile), onDismiss: {
                        isPreviewing = false
                    })
                }
            }
        }
    }
    
    // 加载文件列表
    func loadFiles() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                files = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
                    .filter { $0.hasSuffix(".md") }
            } catch {
                print("无法加载文件列表：\(error.localizedDescription)")
            }
        }
    }
    
    // 加载文件内容
    func loadFileContent(fileName: String) -> String {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
                return content
            }
        }
        return ""
    }
    
    // 删除文件
    func deleteFile(at offsets: IndexSet) {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            for index in offsets {
                let fileName = files[index]
                let fileURL = documentsURL.appendingPathComponent(fileName)
                do {
                    try fileManager.removeItem(at: fileURL)
                    files.remove(at: index)
                } catch {
                    print("无法删除文件：\(error.localizedDescription)")
                }
            }
        }
    }
    
    // 重命名文件
    func renameFile() {
        let fileManager = FileManager.default
        guard currentFileName != renameFileName else { return } // 文件名未变更
        
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let oldFileURL = documentsURL.appendingPathComponent(currentFileName)
            let newFileURL = documentsURL.appendingPathComponent(renameFileName)
            do {
                try fileManager.moveItem(at: oldFileURL, to: newFileURL)
                loadFiles() // 更新文件列表
            } catch {
                print("无法重命名文件：\(error.localizedDescription)")
            }
        }
    }
    
    // 展示文件预览
    func showPreview(for file: String) {
        // 点击文件时显示预览
        isPreviewing = true
    }
}
