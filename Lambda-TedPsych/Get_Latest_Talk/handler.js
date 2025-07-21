const Talk = require('./Talk');
const connect_to_db = require('./db');

// Il nome della funzione esportata è "latest"
module.exports.latest = async (event) => {
  try {
    await connect_to_db();

    const latestTalks = await Talk.find({})
      .sort({ publishedAt: -1 }) // -1 significa ordine decrescente (dal più nuovo al più vecchio)
      .limit(10); // Limita il risultato ai primi 10 talk

    return {
      statusCode: 200,
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(latestTalks)
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Errore nel recuperare gli ultimi talk.' }),
    };
  }
};