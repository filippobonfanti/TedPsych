const Talk = require('./Talk');
const connect_to_db = require('./db');

module.exports.get_watch_next = async (event) => {
  try {
    await connect_to_db();
    const body = JSON.parse(event.body);
    const currentTalkId = body.id; // _id numerico del video di partenza

    // Trova il talk di partenza per ottenere la lista dei suoi ID correlati
    const currentTalk = await Talk.findOne({ _id: currentTalkId });

    if (!currentTalk || !currentTalk.related_talk_ids || currentTalk.related_talk_ids.length === 0) {
      return {
        statusCode: 200,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
        body: JSON.stringify([])
      };
    }

    // Estrai la lista di related_talk_ids (che sono degli internalId)
    const relatedInternalIds = currentTalk.related_talk_ids;
    
    // Cerca tutti i talk il cui campo 'internalId' è presente nella lista che abbiamo estratto
    const relatedTalks = await Talk.find({
      'internalId': { $in: relatedInternalIds }
    });

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify(relatedTalks)
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Errore nel recuperare i video suggeriti.' })
    };
  }
};