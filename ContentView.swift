
import SwiftUI

struct ContentView: View {

    @State private var publicaciones: [Post] = []
    @State private var cargando = false
    @State private var mensajeError: String?

    private let servicio = PostService()

    var body: some View {

        NavigationStack {

            VStack(spacing: 15) {

                Button {
                    Task {
                        await consultarPublicaciones()
                    }
                } label: {

                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("CONSULTAR PUBLICACIONES")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .disabled(cargando)
                .padding(.horizontal)

                if cargando {
                    ProgressView("Consultando servidor...")
                        .padding()
                }

                if let error = mensajeError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                List(publicaciones) { post in

                    VStack(alignment: .leading, spacing: 8) {

                        HStack {
                            Text("PUBLICACIÓN")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Spacer()

                            Text("#\(post.id)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Text(post.title)
                            .font(.headline)
                            .foregroundColor(.red)

                        Text(post.body)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("POSTS")
            .toolbarBackground(Color.red, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    @MainActor
    private func consultarPublicaciones() async {

        cargando = true
        mensajeError = nil

        do {
            publicaciones = try await servicio.obtenerPublicaciones()
        } catch {
            mensajeError = "Error al consultar: \(error.localizedDescription)"
        }

        cargando = false
    }
}
