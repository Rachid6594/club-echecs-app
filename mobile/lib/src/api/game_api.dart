import 'api_client.dart';

class GameApi {
  GameApi(this.client);

  final ApiClient client;

  Map<String, String> buildMoveBody(String gameId, String uci) {
    return {'game_id': gameId, 'uci': uci};
  }

  Map<String, String> buildDrawOfferBody(String gameId) {
    return {'game_id': gameId, 'action': 'offer_draw'};
  }

  Map<String, String> buildResignBody(String gameId) {
    return {'game_id': gameId, 'action': 'resign'};
  }
}
