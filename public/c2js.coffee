s = "
int fib(int i) {
  int f1=0;
  int f2=1;
  int q=0;
  while (q<i-1) {
    int tmp = f2;
    f2 = f1+f2;
    f1 = tmp;
    q = q+1;
  }
  return f1;
}
int main(){
  printf(\"%d\",fib(7));
  return 0;
}
"

sprintf = `function () {
  function str_repeat(j, c) {
    for (var o = []; c > 0; o[--c] = j);
    return o.join('');
  }

	var i = 0, a, f = arguments[i++], o = [], m, p, c, x, s = '';
	while (f) {
		if (m = /^[^\x25]+/.exec(f)) {
			o.push(m[0]);
		}
		else if (m = /^\x25{2}/.exec(f)) {
			o.push('%');
		}
		else if (m = /^\x25(?:(\d+)\$)?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?([b-fosuxX])/.exec(f)) {
			if (((a = arguments[m[1] || i++]) == null) || (a == undefined)) {
				throw('Too few arguments.');
			}
			if (/[^s]/.test(m[7]) && (typeof(a) != 'number')) {
				throw('Expecting number but found ' + typeof(a));
			}
			switch (m[7]) {
				case 'b': a = a.toString(2); break;
				case 'c': a = String.fromCharCode(a); break;
				case 'd': a = parseInt(a); break;
				case 'e': a = m[6] ? a.toExponential(m[6]) : a.toExponential(); break;
				case 'f': a = m[6] ? parseFloat(a).toFixed(m[6]) : parseFloat(a); break;
				case 'o': a = a.toString(8); break;
				case 's': a = ((a = String(a)) && m[6] ? a.substring(0, m[6]) : a); break;
				case 'u': a = Math.abs(a); break;
				case 'x': a = a.toString(16); break;
				case 'X': a = a.toString(16).toUpperCase(); break;
			}
			a = (/[def]/.test(m[7]) && m[2] && a >= 0 ? '+'+ a : a);
			c = m[3] ? m[3] == '0' ? '0' : m[3].charAt(1) : ' ';
			x = m[5] - String(a).length - s.length;
			p = m[5] ? str_repeat(c, x) : '';
			o.push(s + (m[4] ? a + p : p + a));
		}
		else {
			throw('Huh ?!');
		}
		f = f.substring(m[0].length);
	}
	return o.join('');
}`

window.printf = (args...) ->
  s = sprintf args...
  #alert(s)
  document.body.innerHTML += "<p>#{s}</p>"

types = ["int"]

things =
  '\\(': ' ( '
  '\\)': ' ) '
  '{': ' { '
  '}': ' } '
  '=': ' = '
  '-': ' - '
  '>': ' > '
  '<': ' < '
  '\\+': ' + '
  '\\*': ' * '
  '/': ' / '
  ';': ' ; '
  ',': ' , '
  '[+]\\s*[+]': ' ++ '
  '-\\s*-': ' -- '
  '[+]\\s*=': ' += '
  '-\\s*=': ' -= '
  '[*]\\s*=': ' *= '
  '[/]\\s*=': ' /= '

replace_things = (s) ->
  for thing,replacement of things
    s = s.replace(RegExp(thing,'g'), replacement)
  s

copy_til_semi = (output, tokens) ->
  i = 0
  while tokens[i] != ';'
    output.push tokens[i]
    i++
  output.push ';'
  i++
  i

copy_parens_inside = (output, tokens) ->
  i=1
  output.push '('
  oparen_count = 1
  while oparen_count > 0
    switch tokens[i]
      when '('
        oparen_count++
      when ')'
        oparen_count--
    output.push tokens[i]
    i++
  i

copy_parens_inside_rplc_var = (output, tokens) ->
  i=1
  output.push '('
  oparen_count = 1
  while oparen_count > 0
    switch tokens[i]
      when '('
        oparen_count++
      when ')'
        oparen_count--
    if tokens[i] in types
      output.push 'var'
    else
      output.push tokens[i]
    i++
  i

compile = (c_code) ->
  output = []
  c_code = replace_things c_code
  tokens = c_code.split " "
  tokens = tokens.map (t) -> t.trim()
  tokens = tokens.filter (t) -> t != ''
  close_brackets = []
  i=0
  while i < tokens.length
    #debugger
    if tokens[i] in types
      switch tokens[i+2]
        when '('
          # function definition
          output.push 'function'
          output.push tokens[i+1]
          output.push "("
          i=i+3
          while tokens[i] != ')' and tokens[i] != '{'
            i++
            output.push tokens[i]
            output.push ','
            i+=2
          if tokens[i] == ')'
            # no args
            i++
          else
            output.pop()
          output.push ')'
          # at {
          close_brackets.push '}'
          output.push '{'
          i++
        when '='
          # variable assignment and declaration
          i++
          output.push 'var'
          output.push tokens[i]
          output.push '='
          i += 2
          i += copy_til_semi(output, tokens[i..])
        when ';'
          # variable declaration
          output.push 'var'
          i++
          output.push tokens[i]
          output.push ';'
          i+=2
    else
      switch tokens[i]
        when '}'
          output.push close_brackets.pop()
          i++
        when 'while'
          output.push tokens[i]
          i+=1
          i+=copy_parens_inside(output,tokens[i..])
          if tokens[i] == '{'
            output.push '{(function(){'
            close_brackets.push '})();}'
          i++
        when 'for'
          i+=1
          output.push '(function(){'
          output.push 'for'
          i+=copy_parens_inside_rplc_var(output,tokens[i..])
          if tokens[i] == '{'
            output.push '{'
            close_brackets.push '}})();'
          i++
        when 'if'
          output.push tokens[i]
          i+=1
          i+=copy_parens_inside(output,tokens[i..])
          if tokens[i] == '{'
            output.push '{(function(){'
            close_brackets.push '})();}'
          i++
        when 'else'
          output.push tokens[i]
          i+=1
          i+=copy_parens_inside(output,tokens[i..])
          if tokens[i] == '{'
            output.push '{(function(){'
            close_brackets.push '})();}'
          i++
        else
          i += copy_til_semi(output, tokens[i..])
  outputstr = ''
  for put in output
      outputstr += put + ' '
  return outputstr

#while 1
#  i = window.prompt("enter C code here:","")
#  if not i or i == 'quit'
#    break
#  eval(compile i)
#  main()

window.compile = compile

#eval(compile s)
#main()

