const Talk = require('./Talk');
const connect_to_db = require('./db');

module.exports.get_all = async (event) => {
  try {
    await connect_to_db();

    const uniqueTags = await Talk.distinct('tags');

    return {
      statusCode: 200,
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify(uniqueTags)
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Errore nel recuperare i tag.' }),
    };
  }
};