
import SwiftUI

struct ContentView: View {

    @State private var publicaciones: [Post] = []
    @State private var cargando = false
    @State private var mensajeError: String?
    @State private var textoBusqueda = ""

    private let servicio = PostService()

    // Filtrar publicaciones por título
    var publicacionesFiltradas: [Post] {
        if textoBusqueda.isEmpty {
            return publicaciones
        }

        return publicaciones.filter {
            $0.title.localizedCaseInsensitiveContains(textoBusqueda)
        }
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 12) {

                // Botón para consultar publicaciones
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

                // Barra de búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField(
                        "Buscar por título...",
                        text: $textoBusqueda
                    )
                    .autocorrectionDisabled()
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
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

                // Lista de publicaciones filtradas
                List(publicacionesFiltradas) { post in

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

                if !textoBusqueda.isEmpty &&
                    publicacionesFiltradas.isEmpty &&
                    !cargando {

                    Text("No se encontraron publicaciones.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("POSTS")
            .toolbarBackground(Color.red, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task {
            await consultarPublicaciones()
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
