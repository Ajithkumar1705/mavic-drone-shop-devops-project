// Seed demo users from environment variables supplied by the local/Kubernetes runtime.
// Never commit real passwords or personal email addresses to this repository.

const required = (name) => {
    const value = process.env[name];
    if (!value) throw new Error(`Missing required seed variable: ${name}`);
    return value;
};

db = db.getSiblingDB('users');
db.users.insertMany([
    {
        name: required('SEED_USER_NAME'),
        password: required('SEED_USER_PASSWORD'),
        email: required('SEED_USER_EMAIL')
    },
    {
        name: required('SEED_STAN_NAME'),
        password: required('SEED_STAN_PASSWORD'),
        email: required('SEED_STAN_EMAIL')
    },
    {
        name: required('SEED_PARTNER_NAME'),
        password: required('SEED_PARTNER_PASSWORD'),
        email: required('SEED_PARTNER_EMAIL')
    }
]);

db.users.createIndex(
    {name: 1},
    {unique: true}
);
