
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct PostService {

    func obtenerPublicaciones() async throws -> [Post] {

        let url = URL(
            string: "https://jsonplaceholder.typicode.com/posts"
        )!

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let publicaciones = try JSONDecoder().decode(
            [Post].self,
            from: data
        )

        return publicaciones
    }
}
