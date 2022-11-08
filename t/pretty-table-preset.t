use lib 'lib';
use Test;
use Prettier::Table;
use Prettier::Table::Constrains;

my Prettier::Table $original-table .= new:
    field-names => ["City name", "Area", "Population", "Annual Rainfall"],
;

given $original-table {
    .add-row(["Adelaide", 1295, 1158259, 600.5]);
    .add-row(["Brisbane", 5905, 1857594, 1146.4]);
    .add-row(["Darwin", 112, 120900, 1714.7]);
    .add-row(["Hobart", 1357, 205556, 619.5]);
    .add-row(["Sydney", 2058, 4336374, 1214.8]);
    .add-row(["Melbourne", 1566, 3806092, 646.9]);
    .add-row(["Perth", 5386, 1554769, 869.4]);
}

sub basic-setup( $table ) {
    my ($string, @lines, @lengths);
    $string = $table.get-string;
    @lines = $string.split("\n");
    ok "" ∉ @lines, 'No table should ever have blank lines in it.';

    $string = $table.get-string;
    @lines = $string.split("\n");
    @lengths = @lines.map(*.chars);
    ok @lengths.Set.elems == 1, 'All lines in a table should be of the same length.';
}

# Styles can be set via a constant or a string
# e.g. MARKDOWN or 'MARKDOWN'
subtest "Basic setup with MSWORD-FRIENDLY preset style", {
    my $table = $original-table.clone;
    $table.set-style(MSWORD-FRIENDLY);
    basic-setup($table);
}

subtest "Basic setup with MARKDOWN preset style", {
    my $table = $original-table.clone;
    $table.set-style('MARKDOWN');
    $table.align(%('City name' => 'l', 'Annual Rainfall' => 'r'));
    basic-setup($table);
    my $pre_title_lines_count = $table.get-string().split("\n").elems;

    $table.title("WILL BE IGNORED");
    my @lines = $table.get-string().split("\n");
    is @lines.elems, $pre_title_lines_count, "setting table should be ignored";

    # @lines[1] eq "|:----------|------|------------|----------------:|"
    like @lines[1], /^"|:" "-"* ("|" "-"*) ** 3 ":|" $/ , \
        "should have left and right alignment indicators";
    unlike @lines.first, /"-"+/, "should have no top border";
    unlike @lines.tail, /"-"+/, "should have no bottom border";
}

done-testing;
