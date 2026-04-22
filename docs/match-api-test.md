# Match API Test Endpoints

## 1. Match Request (Rakip Ara)
```bash
curl -X POST http://localhost:5238/api/match/request \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**Beklenen**: 200 OK (veya match bulunursa SignalR event)

## 2. Cancel Match Request
```bash
curl -X DELETE http://localhost:5238/api/match/request \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Beklenen**: 200 OK

## 3. Get Match Details
```bash
curl http://localhost:5238/api/match/{matchId} \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:
```json
{
  "id": "guid",
  "status": "InProgress",
  "participants": [...],
  "questions": [...]
}
```

## 4. Get Match History
```bash
curl http://localhost:5238/api/match/history \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**: Array of past matches

## 5. Get Match Stats
```bash
curl http://localhost:5238/api/match/stats/{childId} \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response**:
```json
{
  "gamesPlayed": 10,
  "gamesWon": 6,
  "gamesLost": 4,
  "winRate": 0.6,
  "averageScore": 35.5
}
```

## SignalR Hub Test (Browser Console)

```javascript
// Connect to hub
const connection = new signalR.HubConnectionBuilder()
    .withUrl("http://localhost:5238/hubs/match", {
        accessTokenFactory: () => "YOUR_JWT_TOKEN"
    })
    .build();

// Listen for events
connection.on("MatchFound", (matchData) => {
    console.log("Match found:", matchData);
});

connection.on("OpponentAnswered", (questionNumber, isCorrect) => {
    console.log(`Opponent answered Q${questionNumber}: ${isCorrect}`);
});

connection.on("MatchCompleted", (matchId) => {
    console.log("Match completed:", matchId);
});

// Start connection
await connection.start();
console.log("Connected to Match Hub");

// Join a match
await connection.invoke("JoinMatch", "match-guid-here");

// Submit answer
await connection.invoke("SubmitAnswer", "match-guid", "question-guid", "42");
```

## Database Verification

```sql
-- Check match requests
SELECT * FROM MatchRequests ORDER BY RequestedAt DESC;

-- Check active matches
SELECT * FROM MatchSessions WHERE Status = 'InProgress';

-- Check match participants
SELECT * FROM MatchParticipants WHERE MatchSessionId = 'guid';

-- Check match answers
SELECT * FROM MatchAnswers WHERE MatchSessionId = 'guid' ORDER BY AnsweredAt;
```

## Test Checklist

- [ ] Match request timeout çalışıyor (60s)
- [ ] İki kullanıcı matchmaking bulabiliyor
- [ ] Sınıf seviyesi kontrolü (±1 grade level)
- [ ] SignalR real-time communication çalışıyor
- [ ] Skor hesaplama doğru (10 puan/soru)
- [ ] Match history kaydediliyor
- [ ] Statistics doğru hesaplanıyor
- [ ] Forfeit logic çalışıyor
- [ ] 5 matematik sorusu rastgele seçiliyor
- [ ] Winner determination doğru
