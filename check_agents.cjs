const { PrismaClient } = require('@prisma/client');
const p = new PrismaClient();
p.agent.findMany({ select: { id: true, email: true, type: true } }).then(r => {
  const types = {};
  r.forEach(a => { types[a.type] = (types[a.type] || 0) + 1; });
  console.log(JSON.stringify(types));
  process.exit(0);
}).catch(e => { console.error(e.message); process.exit(1); });
