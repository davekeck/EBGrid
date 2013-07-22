# EBGrid

EBGrid is a collection of functions that factor-out grid-related math for views and other layout code.

## Requirements

- Mac OS 10.8 or iOS 6. (Earlier platforms have not been tested.)

## Integration

1. Integrate [EBFoundation](https://github.com/davekeck/EBFoundation) into your project.
2. Drag EBGrid.xcodeproj into your project's file hierarchy.
3. In your target's "Build Phases" tab:
    * Add EBGrid as a dependency ("Target Dependencies" section)
    * Link against libEBGrid.a ("Link Binary With Libraries" section)
4. Add `#import <EBGrid/EBGrid.h>` to your source files.

## Credits

EBGrid was created for [Lasso](http://las.so).

## License

EBGrid is available under the MIT license; see the LICENSE file for more information.