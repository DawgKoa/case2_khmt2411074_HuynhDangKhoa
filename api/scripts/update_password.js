const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
require('dotenv').config({ path: __dirname + '/../.env' });

async function run() {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to Atlas');

  const salt = await bcrypt.genSalt(10);
  const hash = await bcrypt.hash('0866409678Khoa', salt);
  console.log('Generated hash:', hash);

  const res = await mongoose.connection.collection('users').updateOne(
    { email: 'dangkhoa15022006@gmail.com' },
    { $set: { passwordHash: hash } }
  );
  console.log('Modified count:', res.modifiedCount);

  const user = await mongoose.connection.collection('users').findOne({ email: 'dangkhoa15022006@gmail.com' });
  const check = await bcrypt.compare('0866409678Khoa', user.passwordHash);
  console.log('Direct verification:', check);

  await mongoose.disconnect();
  process.exit(0);
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
