const mongoose = require('mongoose');

const LOCAL_URI = 'mongodb://127.0.0.1:27017/task_manager_db';
const ATLAS_URI = 'mongodb+srv://hdkhoakhmt2411074_db_user:0866409678Khoa@cluster0.ry0ofi8.mongodb.net/task_manager_db?retryWrites=true&w=majority&appName=Cluster0';

async function migrate() {
  console.log('Connecting to Local MongoDB...');
  const localConn = await mongoose.createConnection(LOCAL_URI).asPromise();
  console.log('Connected to Local MongoDB.');

  console.log('Connecting to MongoDB Atlas...');
  const atlasConn = await mongoose.createConnection(ATLAS_URI).asPromise();
  console.log('Connected to MongoDB Atlas.');

  const collections = await localConn.db.listCollections().toArray();
  console.log(`Found ${collections.length} collections in local database:`, collections.map(c => c.name));

  for (const col of collections) {
    const colName = col.name;
    if (colName.startsWith('system.')) continue;

    console.log(`\nMigrating collection: ${colName}...`);
    const localCollection = localConn.collection(colName);
    const atlasCollection = atlasConn.collection(colName);

    const docs = await localCollection.find({}).toArray();
    console.log(`  Found ${docs.length} documents in ${colName}`);

    if (docs.length > 0) {
      // Clear atlas collection first to avoid duplicates
      await atlasCollection.deleteMany({});
      // Insert documents
      const result = await atlasCollection.insertMany(docs);
      console.log(`  Successfully inserted ${result.insertedCount} documents into Atlas ${colName}`);
    }
  }

  console.log('\n=============================================');
  console.log('ALL DATA MIGRATED TO MONGODB ATLAS SUCCESSFULLY!');
  console.log('=============================================');

  await localConn.close();
  await atlasConn.close();
  process.exit(0);
}

migrate().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
