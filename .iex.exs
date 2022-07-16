import Sleipnir

entries = [
  entry("I am a log line"),
  entry("I too am a log line")
]
labels = [
  {"namespace", "loki"},
  {"region", "us-east-1"}
]
stream = stream(entries, labels)
request = request(stream)
client = Sleipnir.Client.Tesla.new("http://localhost:3100", [org_id: "tenant1"])
