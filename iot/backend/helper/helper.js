function getWIBDate(date = new Date()) {
  // UTC +7
  const utc = date.getTime() + date.getTimezoneOffset() * 60000;
  const wib = new Date(utc + 7 * 3600000);
  wib.setDate(wib.getDate()-1);
  return wib;
}
module.exports = {
  getWIBDate
};
