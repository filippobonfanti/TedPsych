const Talk = require('./Talk');
const connect_to_db = require('./db');

module.exports.search = async (event) => {
  try {
    // Connettiti al database all'inizio di ogni esecuzione
    await connect_to_db();

    const body = JSON.parse(event.body);
    const searchTerm = body.searchTerm;

    const talks = await Talk.find({
      $or: [
        { title: { $regex: searchTerm, $options: 'i' } },
        { description: { $regex: searchTerm, $options: 'i' } }
      ]
    }).limit(20);

    // Restituisci i talk trovati nel formato corretto
    return {
      statusCode: 200,
      headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*" // Importante per il frontend
      },
      body: JSON.stringify(talks)
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Errore durante la ricerca.' }),
    };
  }
};