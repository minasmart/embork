define(['handlebars.runtime'], function(Handlebars) {
  Handlebars = Handlebars["default"];  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
return templates['my_handlebars_template.js'] = template({"compiler":[5,">= 2.0.0"],"main":function(depth0,helpers,partials,data) {
  var helper, functionType="function", escapeExpression=this.escapeExpression, helperMissing=helpers.helperMissing;
  return "<p>\n  Hello "
    + escapeExpression(((helper = helpers.name || (depth0 && depth0.name)),(typeof helper === functionType ? helper.call(depth0, {"name":"name","hash":{},"data":data}) : helper)))
    + ", here is a horrible picure:\n  <br />\n  <img "
    + escapeExpression((helper = helpers['bind-attr'] || (depth0 && depth0['bind-attr']) || helperMissing,helper.call(depth0, {"name":"bind-attr","hash":{
    'src': ((depth0 && depth0.someBinding))
  },"data":data})))
    + " />\n</p>\n";
},"useData":true});
});