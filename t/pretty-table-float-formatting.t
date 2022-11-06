use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

plan 3;

my Prettier::Table $table .= new:
    field-names => ["Constant", "Value"],
;

given $table {
    .add-row(["Pi", pi]);
    .add-row(["e", e]);
    .add-row(["sqrt(2)", sqrt(2)]);
}

subtest 'no decimals', {
    $table.float-format(".0f");
    nok $table.get-string.contains("."), "No decimals in table";
}

subtest 'round to five decimal points', {
    $table.float-format(".5f");
    my $string = $table.get-string;

    ok $string.contains("3.14159"), 'Formatted string contains smaller substring';
    nok $string.contains("3.141592"), 'Formatted string doesn\'t contain bigger substring';
    ok $string.contains("2.71828"), 'Formatted string contains smaller substring';
    nok $string.contains("2.718281"), 'Formatted string doesn\'t contain bigger substring';
    nok $string.contains("2.718282"), 'Formatted string doesn\'t contain bigger substring';
    ok $string.contains("1.41421"), 'Formatted string contains smaller substring';
    nok $string.contains("1.414213"), 'Formatted string doesn\'t contain bigger substring';
}

subtest 'pad with two zeroes', {
    $table.float-format("06.2f");
    my $string = $table.get-string;

    ok $string.contains("003.14"), 'Formatted string contains padded substring';
    ok $string.contains("002.72"), 'Formatted string contains padded substring';
    ok $string.contains("001.41"), 'Formatted string contains padded substring';
}

