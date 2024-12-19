def get_filtering [key: string] {
    each { |it|
        if ($it | default [] $key | get $key | is-empty) {
            $nothing
        } else {
            $it | get $key
        }
    }
}

export def main [ls_arg: string] {
    npm ls $ls_arg --json
    | from json
    | get dependencies
    | transpose key value
    | each { |it|
      $it
      | merge {
        dependencies: (
          $it.value
          | get_filtering dependencies
          | transpose key value
          | flatten
          | get_filtering invalid
        )
      }
    }
    | select key dependencies
    | filter { |row|
      not ($row.dependencies | is-empty)
    }
}