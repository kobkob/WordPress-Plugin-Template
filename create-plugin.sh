#!/bin/bash

# WordPress Plugin Template Creator
# Enhanced version with modern development practices
# Supports PHP 8.1+, PHPCS, PHPUnit, and GitHub Actions

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to validate plugin name
validate_plugin_name() {
    local name=$1
    if [[ -z "$name" ]]; then
        print_message $RED "Error: Plugin name cannot be empty"
        return 1
    fi
    if [[ ! "$name" =~ ^[A-Za-z][A-Za-z0-9[:space:]]*$ ]]; then
        print_message $RED "Error: Plugin name must start with a letter and contain only letters, numbers, and spaces"
        return 1
    fi
    return 0
}

# Function to validate destination folder
validate_destination() {
    local folder=$1
    if [[ -z "$folder" ]]; then
        print_message $RED "Error: Destination folder cannot be empty"
        return 1
    fi
    return 0
}

# Function to check if required tools are installed
check_dependencies() {
    local missing_tools=()
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if ! command -v composer &> /dev/null; then
        missing_tools+=("composer")
    fi
    
    if ! command -v node &> /dev/null; then
        missing_tools+=("node")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_message $RED "Error: Missing required tools: ${missing_tools[*]}"
        print_message $YELLOW "Please install the missing tools and run again"
        return 1
    fi
    
    return 0
}

print_message $BLUE "WordPress Plugin Template Creator v2.0"
print_message $BLUE "==========================================="
echo

# Check dependencies
print_message $YELLOW "Checking dependencies..."
if ! check_dependencies; then
    exit 1
fi
print_message $GREEN "✓ All dependencies found"
echo

# Function to read input (handles piped execution)
read_input() {
    local prompt="$1"
    local var_name="$2"
    local default="$3"
    
    # Try to read from /dev/tty first (for piped execution), fall back to stdin
    if [ -t 0 ]; then
        # stdin is a terminal
        printf "$prompt"
        read -r "$var_name"
    elif [ -c /dev/tty ]; then
        # stdin is not a terminal but /dev/tty is available
        printf "$prompt" > /dev/tty
        read -r "$var_name" < /dev/tty
    else
        # Neither stdin nor /dev/tty available, use default if provided
        if [ -n "$default" ]; then
            printf "$prompt (using default: $default)\n"
            eval "$var_name='$default'"
        else
            printf "$prompt"
            read -r "$var_name"
        fi
    fi
}

# Get plugin information
while true; do
    read_input "Plugin name (e.g., 'My Awesome Plugin'): " NAME
    if validate_plugin_name "$NAME"; then
        break
    fi
done

while true; do
    read_input "Destination folder (absolute or relative path): " FOLDER
    if validate_destination "$FOLDER"; then
        break
    fi
done

read_input "Plugin description: " DESCRIPTION
read_input "Author name: " AUTHOR
read_input "Author email: " AUTHOR_EMAIL
read_input "Plugin URI (optional): " PLUGIN_URI

read_input "Include GitHub Actions CI/CD (y/n) [y]: " GITHUB_ACTIONS
GITHUB_ACTIONS=${GITHUB_ACTIONS:-y}

read_input "Include PHPUnit tests (y/n) [y]: " PHPUNIT
PHPUNIT=${PHPUNIT:-y}

read_input "Include WordPress Coding Standards (y/n) [y]: " PHPCS
PHPCS=${PHPCS:-y}

read_input "Include WordPress Feature API for AI/LLM integration (y/n) [y]: " FEATURE_API
FEATURE_API=${FEATURE_API:-y}

read_input "Include REST API endpoints (y/n) [y]: " REST_API
REST_API=${REST_API:-y}

read_input "Include Docker development environment (y/n) [y]: " DOCKER_ENV
DOCKER_ENV=${DOCKER_ENV:-y}

read_input "Include Agile/XP methodology framework (y/n) [y]: " AGILE_FRAMEWORK
AGILE_FRAMEWORK=${AGILE_FRAMEWORK:-y}

read_input "Initialize new git repository (y/n) [y]: " NEWREPO
NEWREPO=${NEWREPO:-y}

# Generate plugin variables
DEFAULT_NAME="WordPress Plugin Template"
DEFAULT_CLASS=${DEFAULT_NAME// /_}
DEFAULT_TOKEN=$(tr '[A-Z]' '[a-z]' <<< "$DEFAULT_CLASS")
DEFAULT_SLUG=${DEFAULT_TOKEN//_/-}

CLASS=${NAME// /_}
TOKEN=$(tr '[A-Z]' '[a-z]' <<< "$CLASS")
SLUG=${TOKEN//_/-}

NAMESPACE=${CLASS//_/\\}

print_message $YELLOW "Creating plugin '$NAME' in '$FOLDER/$SLUG'..."

# Create destination directory
mkdir -p "$FOLDER"
DEST_DIR="$FOLDER/$SLUG"

# Copy template files
print_message $YELLOW "Copying template files..."
cp -r . "$DEST_DIR"

cd "$DEST_DIR"

# Remove template-specific files
print_message $YELLOW "Cleaning up template files..."
rm -rf .git
rm -f create-plugin.sh
rm -f build-plugin.sh
rm -f changelog.txt

# Update main plugin file
print_message $YELLOW "Updating plugin files..."
mv wordpress-plugin-template.php "$SLUG.php"

# Function to replace text in files
replace_in_file() {
    local file=$1
    local search=$2
    local replace=$3
    
    if [[ -f "$file" ]]; then
        # Use a delimiter that's unlikely to appear in the strings
        # First try with different delimiters until we find one that works
        local delimiter
        for delimiter in '|' '#' '@' '%' '~'; do
            if [[ "$search" != *"$delimiter"* && "$replace" != *"$delimiter"* ]]; then
                sed -i.bak "s${delimiter}${search}${delimiter}${replace}${delimiter}g" "$file" && rm -f "$file.bak"
                return 0
            fi
        done
        
        # If no delimiter works, use perl for more robust handling
        if command -v perl >/dev/null 2>&1; then
            perl -i.bak -pe "s/\Q${search}\E/${replace}/g" "$file" && rm -f "$file.bak"
        else
            # Fallback: create temp file and use grep/awk
            local temp_file="${file}.tmp$$"
            awk -v search="$search" -v replace="$replace" '{
                gsub(search, replace)
                print
            }' "$file" > "$temp_file" && mv "$temp_file" "$file"
        fi
    fi
}

# Update all files with new plugin information
files_to_update=(
    "$SLUG.php"
    "readme.txt" 
    "includes/class-$DEFAULT_SLUG.php"
    "includes/class-$DEFAULT_SLUG-settings.php"
    "includes/lib/class-$DEFAULT_SLUG-admin-api.php"
    "includes/lib/class-$DEFAULT_SLUG-post-type.php"
    "includes/lib/class-$DEFAULT_SLUG-taxonomy.php"
    "includes/lib/class-$DEFAULT_SLUG-feature-api.php"
    "lang/$DEFAULT_SLUG.pot"
)

# Add REST API file to update list if enabled
if [[ "$REST_API" == "y" ]]; then
    files_to_update+=("includes/lib/class-$DEFAULT_SLUG-rest-api.php")
fi

# Rename class files
mv "includes/class-$DEFAULT_SLUG.php" "includes/class-$SLUG.php"
mv "includes/class-$DEFAULT_SLUG-settings.php" "includes/class-$SLUG-settings.php"
mv "includes/lib/class-$DEFAULT_SLUG-admin-api.php" "includes/lib/class-$SLUG-admin-api.php"
mv "includes/lib/class-$DEFAULT_SLUG-post-type.php" "includes/lib/class-$SLUG-post-type.php"
mv "includes/lib/class-$DEFAULT_SLUG-taxonomy.php" "includes/lib/class-$SLUG-taxonomy.php"
mv "includes/lib/class-$DEFAULT_SLUG-feature-api.php" "includes/lib/class-$SLUG-feature-api.php"
if [[ "$REST_API" == "y" ]]; then
    mv "includes/lib/class-$DEFAULT_SLUG-rest-api.php" "includes/lib/class-$SLUG-rest-api.php"
fi
mv "lang/$DEFAULT_SLUG.pot" "lang/$SLUG.pot"

# Update file contents
for file in "${files_to_update[@]}"; do
    file=${file//$DEFAULT_SLUG/$SLUG}
    if [[ -f "$file" ]]; then
        replace_in_file "$file" "$DEFAULT_NAME" "$NAME"
        replace_in_file "$file" "$DEFAULT_CLASS" "$CLASS"
        replace_in_file "$file" "$DEFAULT_TOKEN" "$TOKEN"
        replace_in_file "$file" "$DEFAULT_SLUG" "$SLUG"
        
        # Add author and description if provided
        if [[ -n "$AUTHOR" ]]; then
            replace_in_file "$file" "Hugh Lashbrooke" "$AUTHOR"
        fi
        if [[ -n "$DESCRIPTION" && "$file" == "$SLUG.php" ]]; then
            replace_in_file "$file" "This is your starter template for your next WordPress plugin." "$DESCRIPTION"
        fi
        if [[ -n "$PLUGIN_URI" && "$file" == "$SLUG.php" ]]; then
            replace_in_file "$file" "https://github.com/kobkob/WordPress-Plugin-Template" "$PLUGIN_URI"
        fi
    fi
done

# Remove REST API files if not requested
if [[ "$REST_API" != "y" ]]; then
    print_message $YELLOW "Removing REST API files..."
    rm -f "includes/lib/class-$SLUG-rest-api.php"
    rm -f "REST-API-GUIDE.md"
    
    # Remove REST API test files if they exist
    rm -f "tests/integration/test-wordpress-plugin-template-rest-api.php"
    rm -f "tests/unit/test-wordpress-plugin-template-rest-api-unit.php"
    
    # Remove REST API references from main plugin file
    replace_in_file "$SLUG.php" "require_once( 'includes/lib/class-$DEFAULT_SLUG-rest-api.php' );" ""
    replace_in_file "$SLUG.php" "require_once( 'includes/lib/class-$SLUG-rest-api.php' );" ""
    
    # Handle complex multi-line REST API initialization removal
    # Use a more robust method for multiline replacement
    if [[ -f "$SLUG.php" ]]; then
        # Create a temporary file to store the REST API initialization block
        cat > /tmp/rest_api_block.$$ << 'BLOCK_EOF'
	// Initialize REST API
	if ( is_null( $instance->rest_api ) ) {
		$instance->rest_api = CLASS_NAME_REST_API::instance( $instance );
	}
BLOCK_EOF
        
        # Replace the placeholder with actual class name using safe approach
        # Use replace_in_file function which handles special characters properly
        cp /tmp/rest_api_block.$$ /tmp/rest_api_actual_block.$$
        replace_in_file "/tmp/rest_api_actual_block.$$" "CLASS_NAME" "$CLASS"
        
        # Use grep -v to remove lines containing the REST API initialization
        grep -v -F "Initialize REST API" "$SLUG.php" | grep -v -F "rest_api = ${CLASS}_REST_API::instance" > "$SLUG.php.tmp"
        mv "$SLUG.php.tmp" "$SLUG.php"
        
        # Clean up temp files
        rm -f /tmp/rest_api_block.$$ /tmp/rest_api_actual_block.$$
    fi
fi

# Remove Docker files if not requested
if [[ "$DOCKER_ENV" != "y" ]]; then
    print_message $YELLOW "Removing Docker development environment..."
    rm -f docker-compose.yml
    rm -rf docker/
    rm -f .dockerignore
    rm -f .env.example
    rm -f DOCKER.md
fi

# Remove Agile framework files if not requested
if [[ "$AGILE_FRAMEWORK" != "y" ]]; then
    print_message $YELLOW "Removing Agile/XP methodology framework..."
    rm -rf agile/
    rm -f AGILE-GUIDE.md
fi

# Create composer.json
if [[ "$PHPUNIT" == "y" || "$PHPCS" == "y" || "$FEATURE_API" == "y" ]]; then
    print_message $YELLOW "Creating composer.json..."
    cat > composer.json << EOF
{
    "name": "$(echo "$AUTHOR_EMAIL" | cut -d'@' -f1)/$SLUG",
    "description": "$DESCRIPTION",
    "type": "wordpress-plugin",
    "license": "GPL-3.0-or-later",
    "authors": [
        {
            "name": "$AUTHOR",
            "email": "$AUTHOR_EMAIL"
        }
    ],
    "require": {
        "php": ">=8.1"
EOF

    # Add WP Feature API if requested
    if [[ "$FEATURE_API" == "y" ]]; then
        cat >> composer.json << EOF
,
        "automattic/wp-feature-api": "^0.1.8"
EOF
    fi

    cat >> composer.json << EOF
    },
    "require-dev": {
EOF

    if [[ "$PHPUNIT" == "y" ]]; then
        cat >> composer.json << EOF
        "phpunit/phpunit": "^10.0",
        "yoast/wp-test-utils": "^1.0",
EOF
    fi

    if [[ "$PHPCS" == "y" ]]; then
        cat >> composer.json << EOF
        "wp-coding-standards/wpcs": "*",
        "phpcompatibility/phpcompatibility-wp": "*",
        "dealerdirect/phpcodesniffer-composer-installer": "^0.7",
EOF
    fi

    cat >> composer.json << EOF
        "php-stubs/wordpress-stubs": "^6.0"
    },
    "config": {
        "allow-plugins": {
            "dealerdirect/phpcodesniffer-composer-installer": true
        }
    },
    "scripts": {
        "test": "phpunit",
        "cs": "phpcs",
        "cbf": "phpcbf"
    }
}
EOF
fi

# Create phpcs.xml
if [[ "$PHPCS" == "y" ]]; then
    print_message $YELLOW "Creating PHPCS configuration..."
    cat > phpcs.xml << 'EOF'
<?xml version="1.0"?>
<ruleset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="WordPress Plugin Coding Standards" xsi:noNamespaceSchemaLocation="https://raw.githubusercontent.com/squizlabs/PHP_CodeSniffer/master/phpcs.xsd">
    <description>WordPress Coding Standards for Plugin</description>

    <!-- Show progress and sniff codes -->
    <arg value="ps"/>
    
    <!-- Show colors in output -->
    <arg name="colors"/>
    
    <!-- Check up to 8 files simultaneously -->
    <arg name="parallel" value="8"/>
    
    <!-- Paths to check -->
    <file>.</file>
    
    <!-- Exclude paths -->
    <exclude-pattern>*/node_modules/*</exclude-pattern>
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/tests/*</exclude-pattern>
    <exclude-pattern>*/assets/*</exclude-pattern>
    
    <!-- Include the WordPress-Extra standard -->
    <rule ref="WordPress-Extra">
        <!-- Allow short array syntax -->
        <exclude name="Generic.Arrays.DisallowShortArraySyntax"/>
    </rule>

    <!-- Include WordPress-Docs standard -->
    <rule ref="WordPress-Docs"/>

    <!-- Let's also check that everything is properly prefixed -->
    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <!-- Value: replace the function, class, and variable prefixes used. Separate multiple prefixes with a comma -->
            <property name="prefixes" type="array" value="{TOKEN}"/>
        </properties>
    </rule>

    <!-- Check for PHP compatibility -->
    <rule ref="PHPCompatibilityWP"/>
    <config name="testVersion" value="8.1-8.4"/>
</ruleset>
EOF
    
    # Replace {TOKEN} with actual token
    replace_in_file "phpcs.xml" "{TOKEN}" "$TOKEN"
fi

# Create PHPUnit configuration and tests
if [[ "$PHPUNIT" == "y" ]]; then
    print_message $YELLOW "Setting up PHPUnit tests..."
    
    # Create phpunit.xml
    cat > phpunit.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="https://schema.phpunit.de/10.0/phpunit.xsd"
         bootstrap="tests/bootstrap.php"
         colors="true"
         convertErrorsToExceptions="true"
         convertNoticesToExceptions="true"
         convertWarningsToExceptions="true"
         processIsolation="false"
         stopOnFailure="false"
         testdox="true">
    <testsuites>
        <testsuite name="Unit Tests">
            <directory>tests/unit</directory>
        </testsuite>
        <testsuite name="Integration Tests">
            <directory>tests/integration</directory>
        </testsuite>
    </testsuites>
    <php>
        <const name="WP_TESTS_PHPUNIT_POLYFILLS_PATH" value="vendor/yoast/wp-test-utils/phpunitpolyfills-autoload.php"/>
    </php>
    <coverage>
        <include>
            <directory suffix=".php">includes</directory>
        </include>
        <exclude>
            <directory>tests</directory>
            <directory>vendor</directory>
            <directory>node_modules</directory>
        </exclude>
    </coverage>
</phpunit>
EOF

    # Create tests directory structure
    mkdir -p tests/{unit,integration}
    
    # Create bootstrap file
    cat > tests/bootstrap.php << EOF
<?php
/**
 * PHPUnit bootstrap file for $NAME
 */

// Define test environment
define( 'WP_TESTS_PHPUNIT_POLYFILLS_PATH', dirname( __DIR__ ) . '/vendor/yoast/wp-test-utils/phpunitpolyfills-autoload.php' );

// Load WordPress test environment
\$_tests_dir = getenv( 'WP_TESTS_DIR' );
if ( ! \$_tests_dir ) {
    \$_tests_dir = rtrim( sys_get_temp_dir(), '/\\' ) . '/wordpress-tests-lib';
}

if ( ! file_exists( \$_tests_dir . '/includes/functions.php' ) ) {
    echo "Could not find \$_tests_dir/includes/functions.php, have you run bin/install-wp-tests.sh ?" . PHP_EOL;
    exit( 1 );
}

// Give access to tests_add_filter() function
require_once \$_tests_dir . '/includes/functions.php';

/**
 * Manually load the plugin being tested
 */
function _manually_load_plugin() {
    require dirname( __DIR__ ) . '/$SLUG.php';
}
tests_add_filter( 'muplugins_loaded', '_manually_load_plugin' );

// Start up the WP testing environment
require \$_tests_dir . '/includes/bootstrap.php';
EOF

    # Create sample unit test
    cat > tests/unit/test-${SLUG}.php << EOF
<?php
/**
 * Unit tests for main plugin class
 */

class Test_${CLASS} extends WP_UnitTestCase {

    protected \$plugin;

    public function setUp(): void {
        parent::setUp();
        \$this->plugin = ${CLASS}();
    }

    public function test_plugin_instance() {
        \$this->assertInstanceOf( '${CLASS}', \$this->plugin );
    }

    public function test_plugin_version() {
        \$this->assertNotEmpty( \$this->plugin->_version );
    }

    public function test_plugin_token() {
        \$this->assertEquals( '${TOKEN}', \$this->plugin->_token );
    }

    public function test_enqueue_styles() {
        \$this->plugin->enqueue_styles();
        \$this->assertTrue( wp_style_is( '${TOKEN}-frontend', 'registered' ) );
    }

    public function test_enqueue_scripts() {
        \$this->plugin->enqueue_scripts();
        \$this->assertTrue( wp_script_is( '${TOKEN}-frontend', 'registered' ) );
    }
}
EOF

    # Create sample integration test
    cat > tests/integration/test-${SLUG}-integration.php << EOF
<?php
/**
 * Integration tests for $NAME
 */

class Test_${CLASS}_Integration extends WP_UnitTestCase {

    public function test_plugin_activation() {
        \$this->assertTrue( is_plugin_active( plugin_basename( dirname( __DIR__, 2 ) . '/$SLUG.php' ) ) );
    }

    public function test_post_type_registration() {
        \$plugin = ${CLASS}();
        
        // Test post type registration
        \$post_type = \$plugin->register_post_type( 'test_type', 'Test Types', 'Test Type' );
        \$this->assertNotNull( \$post_type );
    }

    public function test_taxonomy_registration() {
        \$plugin = ${CLASS}();
        
        // Test taxonomy registration
        \$taxonomy = \$plugin->register_taxonomy( 'test_tax', 'Test Taxonomies', 'Test Taxonomy', array( 'post' ) );
        \$this->assertNotNull( \$taxonomy );
    }
}
EOF

    # Add REST API tests if REST API is enabled
    if [[ "$REST_API" == "y" ]]; then
        print_message $YELLOW "Adding REST API test files..."
        
        # Copy REST API integration test
        cp "tests/integration/test-wordpress-plugin-template-rest-api.php" "tests/integration/test-${SLUG}-rest-api.php"
        
        # Copy REST API unit test
        cp "tests/unit/test-wordpress-plugin-template-rest-api-unit.php" "tests/unit/test-${SLUG}-rest-api-unit.php"
        
        # Update the test files with new plugin information
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "WordPress_Plugin_Template" "$CLASS"
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "wordpress-plugin-template" "$SLUG"
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "WordPress Plugin Template" "$NAME"
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "wpt_" "${TOKEN}_"
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "WordPress_Plugin_Template_REST_API" "${CLASS}_REST_API"
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "WordPress_Plugin_Template_Settings" "${CLASS}_Settings"
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "wordpress_plugin_template_item" "${TOKEN}_item"
        replace_in_file "tests/integration/test-${SLUG}-rest-api.php" "Test_WordPress_Plugin_Template_REST_API" "Test_${CLASS}_REST_API"
        
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "WordPress_Plugin_Template" "$CLASS"
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "wordpress-plugin-template" "$SLUG"
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "WordPress Plugin Template" "$NAME"
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "wpt_" "${TOKEN}_"
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "WordPress_Plugin_Template_REST_API" "${CLASS}_REST_API"
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "WordPress_Plugin_Template_Settings" "${CLASS}_Settings"
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "wordpress_plugin_template_item" "${TOKEN}_item"
        replace_in_file "tests/unit/test-${SLUG}-rest-api-unit.php" "Test_WordPress_Plugin_Template_REST_API_Unit" "Test_${CLASS}_REST_API_Unit"
    fi

    # Create install script for WordPress tests
    cat > bin/install-wp-tests.sh << 'EOF'
#!/usr/bin/env bash

if [ $# -lt 3 ]; then
	echo "usage: $0 <db-name> <db-user> <db-pass> [db-host] [wp-version] [skip-database-creation]"
	exit 1
fi

DB_NAME=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=${4-localhost}
WP_VERSION=${5-latest}
SKIP_DB_CREATE=${6-false}

WP_TESTS_DIR=${WP_TESTS_DIR-/tmp/wordpress-tests-lib}
WP_CORE_DIR=${WP_CORE_DIR-/tmp/wordpress/}

download() {
    if [ `which curl` ]; then
        curl -s "$1" > "$2";
    elif [ `which wget` ]; then
        wget -nv -O "$2" "$1"
    fi
}

if [[ $WP_VERSION =~ ^[0-9]+\.[0-9]+$ ]]; then
	WP_TESTS_TAG="branches/$WP_VERSION"
elif [[ $WP_VERSION =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
	if [[ $WP_VERSION =~ [0-9]+\.[0-9]+\.[0] ]]; then
		# version x.x.0 means the first release of the major version, so strip off the .0 and download version x.x
		WP_TESTS_TAG="tags/${WP_VERSION%??}"
	else
		WP_TESTS_TAG="tags/$WP_VERSION"
	fi
elif [[ $WP_VERSION == 'nightly' || $WP_VERSION == 'trunk' ]]; then
	WP_TESTS_TAG="trunk"
else
	# http serves a single offer, whereas https serves multiple. we only want one
	download http://api.wordpress.org/core/version-check/1.7/ /tmp/wp-latest.json
	grep '[0-9]+\.[0-9]+(\.[0-9]+)?' /tmp/wp-latest.json
	LATEST_VERSION=$(grep -o '"version":"[^"]*' /tmp/wp-latest.json | sed 's/"version":"//')
	if [[ -z "$LATEST_VERSION" ]]; then
		echo "Latest WordPress version could not be found"
		exit 1
	fi
	WP_TESTS_TAG="tags/$LATEST_VERSION"
fi

set -ex

install_wp() {

	if [ -d $WP_CORE_DIR ]; then
		return;
	fi

	mkdir -p $WP_CORE_DIR

	if [[ $WP_VERSION == 'nightly' || $WP_VERSION == 'trunk' ]]; then
		mkdir -p /tmp/wordpress-nightly
		download https://wordpress.org/nightly-builds/wordpress-latest.zip  /tmp/wordpress-nightly/wordpress-nightly.zip
		unzip -q /tmp/wordpress-nightly/wordpress-nightly.zip -d /tmp/wordpress-nightly/
		mv /tmp/wordpress-nightly/wordpress/* $WP_CORE_DIR
	else
		if [ $WP_VERSION == 'latest' ]; then
			local ARCHIVE_NAME='latest'
		elif [[ $WP_VERSION =~ [0-9]+\.[0-9]+ ]]; then
			if [[ $WP_VERSION =~ [0-9]+\.[0-9]+\.[0] ]]; then
				# version x.x.0 means the first release of the major version, so strip off the .0 and download version x.x
				local ARCHIVE_NAME=${WP_VERSION%??}
			else
				local ARCHIVE_NAME=$WP_VERSION
			fi
		else
			local ARCHIVE_NAME=$WP_VERSION
		fi
		download https://wordpress.org/wordpress-${ARCHIVE_NAME}.tar.gz  /tmp/wordpress.tar.gz
		tar --strip-components=1 -zxmf /tmp/wordpress.tar.gz -C $WP_CORE_DIR
	fi

	download https://raw.githubusercontent.com/markoheijnen/wp-mysqli/master/db.php $WP_CORE_DIR/wp-content/db.php
}

install_test_suite() {
	if [ ! -d $WP_TESTS_DIR ]; then
		mkdir -p $WP_TESTS_DIR
		svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/includes/ $WP_TESTS_DIR/includes
		svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/data/ $WP_TESTS_DIR/data
	fi

	if [ ! -f wp-tests-config.php ]; then
		download https://develop.svn.wordpress.org/${WP_TESTS_TAG}/wp-tests-config-sample.php "$WP_TESTS_DIR"/wp-tests-config.php
		WP_CORE_DIR_ESCAPED=$(echo $WP_CORE_DIR | sed 's/\//\\\//g')
		sed -i "s:dirname( __FILE__ ) . '/src/':'$WP_CORE_DIR_ESCAPED':" "$WP_TESTS_DIR"/wp-tests-config.php
		sed -i "s/youremptytestdbnamehere/$DB_NAME/" "$WP_TESTS_DIR"/wp-tests-config.php
		sed -i "s/yourusernamehere/$DB_USER/" "$WP_TESTS_DIR"/wp-tests-config.php
		sed -i "s/yourpasswordhere/$DB_PASS/" "$WP_TESTS_DIR"/wp-tests-config.php
		sed -i "s|localhost|${DB_HOST}|" "$WP_TESTS_DIR"/wp-tests-config.php
	fi

}

install_db() {

	if [ ${SKIP_DB_CREATE} = "true" ]; then
		return 0
	fi

	# parse DB_HOST for port or socket references
	local PARTS=(${DB_HOST//\:/ })
	local DB_HOSTNAME=${PARTS[0]};
	local DB_SOCK_OR_PORT=${PARTS[1]};
	local EXTRA=""

	if ! [ -z $DB_HOSTNAME ] ; then
		if [ $(echo $DB_SOCK_OR_PORT | grep -e '^[0-9]\{1,\}$') ]; then
			EXTRA=" --port=$DB_SOCK_OR_PORT --protocol=tcp"
		elif ! [ -z $DB_SOCK_OR_PORT ] ; then
			EXTRA=" --socket=$DB_SOCK_OR_PORT"
		fi
	fi

	# create database
	mysqladmin create $DB_NAME --user="$DB_USER" --password="$DB_PASS"$EXTRA
}

install_wp
install_test_suite
install_db
EOF

    chmod +x bin/install-wp-tests.sh
    mkdir -p bin
fi

# Create GitHub Actions workflow
if [[ "$GITHUB_ACTIONS" == "y" ]]; then
    print_message $YELLOW "Setting up GitHub Actions..."
    mkdir -p .github/workflows
    
    cat > .github/workflows/ci.yml << EOF
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        php: ['8.1', '8.2', '8.3', '8.4']
        wp: ['latest', '6.0']
        exclude:
          # Exclude PHP 8.4 with older WordPress versions until better support
          - php: '8.4'
            wp: '6.0'
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: wordpress_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: \${{ matrix.php }}
        extensions: dom, curl, libxml, mbstring, zip, pcntl, pdo, sqlite, pdo_sqlite, mysql, mysqli, pdo_mysql, bcmath, soap, intl, gd, exif, iconv
        coverage: none
    
    - name: Cache Composer packages
      id: composer-cache
      uses: actions/cache@v3
      with:
        path: vendor
        key: \${{ runner.os }}-php-\${{ matrix.php }}-\${{ hashFiles('**/composer.lock') }}
        restore-keys: |
          \${{ runner.os }}-php-\${{ matrix.php }}-
    
    - name: Install dependencies
      run: composer install --prefer-dist --no-progress
EOF

    if [[ "$PHPCS" == "y" ]]; then
        cat >> .github/workflows/ci.yml << EOF
    
    - name: Run PHPCS
      run: composer run-script cs
EOF
    fi

    if [[ "$PHPUNIT" == "y" ]]; then
        cat >> .github/workflows/ci.yml << EOF
    
    - name: Install WordPress Test Suite
      run: |
        bash bin/install-wp-tests.sh wordpress_test root root 127.0.0.1 \${{ matrix.wp }}
    
    - name: Run PHPUnit
      run: composer run-script test
EOF
    fi
fi

# Update package.json if it exists
if [[ -f "package.json" ]]; then
    print_message $YELLOW "Updating package.json..."
    cat > package.json << EOF
{
    "name": "$SLUG",
    "title": "$NAME",
    "version": "1.0.0",
    "description": "$DESCRIPTION",
    "main": "Gruntfile.js",
    "scripts": {
        "build": "grunt build",
        "watch": "grunt watch",
        "dev": "grunt dev"
    },
    "devDependencies": {
        "grunt": "^1.5.0",
        "grunt-contrib-uglify": "^5.0.0",
        "grunt-contrib-less": "^3.0.0",
        "grunt-contrib-cssmin": "^4.0.0",
        "grunt-contrib-watch": "^1.1.0"
    }
}
EOF
fi

# Install dependencies
if [[ "$PHPUNIT" == "y" || "$PHPCS" == "y" ]]; then
    print_message $YELLOW "Installing Composer dependencies..."
    composer install --no-dev
fi

# Initialize git repository
if [[ "$NEWREPO" == "y" ]]; then
    print_message $YELLOW "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: Created $NAME from WordPress Plugin Template"
fi

print_message $GREEN "✓ Plugin '$NAME' created successfully!"
print_message $BLUE "Location: $DEST_DIR"
echo
print_message $YELLOW "Next steps:"
if [[ "$DOCKER_ENV" == "y" ]]; then
    echo "1. Start Docker development environment: docker-compose up -d"
    echo "2. Access WordPress: http://localhost:8000"
    echo "3. Access phpMyAdmin: http://localhost:8080"
    echo "4. See DOCKER.md for complete usage guide"
fi
if [[ "$PHPUNIT" == "y" || "$PHPCS" == "y" ]]; then
    if [[ "$DOCKER_ENV" == "y" ]]; then
        echo "5. Run 'composer install' to install development dependencies"
    else
        echo "1. Run 'composer install' to install development dependencies"
    fi
fi
if [[ "$PHPUNIT" == "y" ]]; then
    if [[ "$DOCKER_ENV" == "y" ]]; then
        echo "6. Run tests inside Docker: docker-compose exec wp-cli bash -c 'cd /var/www/html/wp-content/plugins/$SLUG && composer test'"
    else
        echo "2. Set up WordPress test environment: ./bin/install-wp-tests.sh wordpress_test root '' localhost latest"
        echo "3. Run tests: composer test"
    fi
fi
if [[ "$PHPCS" == "y" ]]; then
    if [[ "$DOCKER_ENV" == "y" ]]; then
        echo "7. Check coding standards: docker-compose exec wp-cli bash -c 'cd /var/www/html/wp-content/plugins/$SLUG && composer cs'"
    else
        echo "4. Check coding standards: composer cs"
    fi
fi
if [[ "$AGILE_FRAMEWORK" == "y" ]]; then
    if [[ "$DOCKER_ENV" == "y" ]]; then
        echo "8. Use Agile/XP methodology: see AGILE-GUIDE.md for workflow"
        echo "9. Start a sprint: ./agile/scripts/start-sprint.sh"
        echo "10. Start developing your plugin!"
    else
        echo "5. Use Agile/XP methodology: see AGILE-GUIDE.md for workflow"
        echo "6. Start a sprint: ./agile/scripts/start-sprint.sh"
        echo "7. Start developing your plugin!"
    fi
else
    if [[ "$DOCKER_ENV" == "y" ]]; then
        echo "8. Start developing your plugin!"
    else
        echo "5. Start developing your plugin!"
    fi
fi
echo

print_message $GREEN "Happy coding! 🚀"
