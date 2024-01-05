import {
  Decimal,
  objectEnumValues,
  makeStrictEnum
} from './runtime/index-browser.mjs'

const Prisma = {}

/**
 * Prisma Client JS version: 4.15.0-integration-feat-client-esm.27
 * Query Engine version: 8fbc245156db7124f997f4cecdd8d1219e360944
 */
Prisma.prismaVersion = {
  client: "4.15.0-integration-feat-client-esm.27",
  engine: "8fbc245156db7124f997f4cecdd8d1219e360944"
}

Prisma.PrismaClientKnownRequestError = () => {
  throw new Error(`PrismaClientKnownRequestError is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)};
Prisma.PrismaClientUnknownRequestError = () => {
  throw new Error(`PrismaClientUnknownRequestError is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.PrismaClientRustPanicError = () => {
  throw new Error(`PrismaClientRustPanicError is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.PrismaClientInitializationError = () => {
  throw new Error(`PrismaClientInitializationError is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.PrismaClientValidationError = () => {
  throw new Error(`PrismaClientValidationError is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.NotFoundError = () => {
  throw new Error(`NotFoundError is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.Decimal = Decimal

/**
 * Re-export of sql-template-tag
 */
Prisma.sql = () => {
  throw new Error(`sqltag is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.empty = () => {
  throw new Error(`empty is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.join = () => {
  throw new Error(`join is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.raw = () => {
  throw new Error(`raw is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
)}
Prisma.validator = () => (val) => val


/**
 * Shorthand utilities for JSON filtering
 */
Prisma.DbNull = objectEnumValues.instances.DbNull
Prisma.JsonNull = objectEnumValues.instances.JsonNull
Prisma.AnyNull = objectEnumValues.instances.AnyNull
Prisma.NullTypes = {
  DbNull: objectEnumValues.classes.DbNull,
  JsonNull: objectEnumValues.classes.JsonNull,
  AnyNull: objectEnumValues.classes.AnyNull
}

/**
 * Enums
 */

Prisma.PaymentScalarFieldEnum = {
  id: 'id',
  payerPubkey: 'payerPubkey',
  zapRequest: 'zapRequest',
  zappedEvent: 'zappedEvent',
  zapEndpoint: 'zapEndpoint',
  receiverPubkey: 'receiverPubkey',
  satsAmount: 'satsAmount',
  tierName: 'tierName',
  validUntil: 'validUntil',
  paid: 'paid',
  createdAt: 'createdAt',
  updatedAt: 'updatedAt'
};

Prisma.QueryMode = {
  default: 'default',
  insensitive: 'insensitive'
};

Prisma.SortOrder = {
  asc: 'asc',
  desc: 'desc'
};

Prisma.TransactionIsolationLevel = makeStrictEnum({
  ReadUncommitted: 'ReadUncommitted',
  ReadCommitted: 'ReadCommitted',
  RepeatableRead: 'RepeatableRead',
  Serializable: 'Serializable'
});

Prisma.UserScalarFieldEnum = {
  pubkey: 'pubkey',
  createdAt: 'createdAt',
  updatedAt: 'updatedAt'
};

Prisma.WalletConnectScalarFieldEnum = {
  uri: 'uri',
  pubkey: 'pubkey',
  createdAt: 'createdAt',
  updatedAt: 'updatedAt'
};


Prisma.ModelName = {
  User: 'User',
  WalletConnect: 'WalletConnect',
  Payment: 'Payment'
};

/**
 * Create the Client
 */
class PrismaClient {
  constructor() {
    throw new Error(
      `PrismaClient is unable to be run in the browser.
In case this error is unexpected for you, please report it in https://github.com/prisma/prisma/issues`,
    )
  }
}

export { Prisma, PrismaClient }
export default { Prisma, PrismaClient }
