import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct CaseInputView: View {
    @State private var caseText: String = ""
    @State private var isShowingDocumentPicker = false
    @State private var isGeneratingBrief = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // File upload section
                VStack {
                    Text("Upload Case File")
                        .font(.headline)
                    Text("Supported formats: PDF, DOC, DOCX, TXT")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: { isShowingDocumentPicker = true }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("Select File")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Text input section
                VStack(alignment: .leading) {
                    Text("Or Paste Case Text")
                        .font(.headline)
                    
                    TextEditor(text: $caseText)
                        .frame(minHeight: 200)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    if !caseText.isEmpty {
                        Button(action: { isGeneratingBrief = true }) {
                            Text("Generate Brief")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Input Case")
        .fileImporter(
            isPresented: $isShowingDocumentPicker,
            allowedContentTypes: [.pdf, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $isGeneratingBrief) {
            if !caseText.isEmpty {
                CaseDetailView(legalCase: nil, caseText: caseText)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            let fileURLs = try result.get()
            guard let selectedFile = fileURLs.first else { return }
            
            if selectedFile.startAccessingSecurityScopedResource() {
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                
                switch selectedFile.pathExtension.lowercased() {
                case "txt":
                    caseText = try String(contentsOf: selectedFile, encoding: .utf8)
                    
                case "pdf":
                    // We'll need to add PDFKit for this
                    if let pdf = PDFDocument(url: selectedFile) {
                        caseText = extractTextFromPDF(pdf)
                    }
                    
                case "doc", "docx":
                    // For Word documents, we might want to use a third-party library
                    // or suggest converting to PDF first
                    errorMessage = "Word documents are not currently supported. Please convert to PDF or copy/paste the text."
                    
                default:
                    errorMessage = "Unsupported file format"
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func extractTextFromPDF(_ pdf: PDFDocument) -> String {
        var text = ""
        for i in 0..<pdf.pageCount {
            if let page = pdf.page(at: i) {
                text += page.string ?? ""
            }
        }
        return text
    }
} 