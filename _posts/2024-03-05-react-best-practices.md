---
title: "React Best Practices: Lessons from Building Production Apps"
date: 2024-03-05 09:15:00 +0800
categories: [Tutorials, Frontend]
tags: [react, javascript, best-practices, performance, clean-code]
---

# React Best Practices: Lessons Learned from Production

After building several React applications in production, I've learned valuable lessons about writing maintainable, performant, and scalable React code. Here are the key best practices I follow.

## 1. Component Structure and Organization

### File Organization
```
src/
├── components/
│   ├── common/          # Reusable UI components
│   ├── layout/          # Layout components
│   └── features/        # Feature-specific components
├── hooks/               # Custom hooks
├── utils/               # Helper functions
├── services/            # API calls
└── constants/           # Application constants
```

### Component Naming Convention
```javascript
// ✅ Good: PascalCase for components
const UserProfile = () => {
  return <div>User Profile</div>;
};

// ✅ Good: Descriptive names
const ProductSearchForm = () => {
  // Component logic
};

// ❌ Avoid: Generic names
const Component1 = () => {
  // Component logic
};
```

## 2. State Management Best Practices

### Use Local State When Possible
```javascript
// ✅ Good: Local state for component-specific data
const UserForm = () => {
  const [formData, setFormData] = useState({
    name: '',
    email: ''
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    // Handle form submission
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
    </form>
  );
};
```

### Lift State Up When Needed
```javascript
// ✅ Good: Shared state at appropriate level
const ParentComponent = () => {
  const [sharedData, setSharedData] = useState([]);

  return (
    <div>
      <ChildA data={sharedData} onUpdate={setSharedData} />
      <ChildB data={sharedData} />
    </div>
  );
};
```

## 3. Custom Hooks for Reusable Logic

### API Data Fetching Hook
```javascript
// Custom hook for API calls
const useApi = (url) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url);
        if (!response.ok) throw new Error('API call failed');
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};

// Usage in component
const ProductList = () => {
  const { data: products, loading, error } = useApi('/api/products');

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;

  return (
    <div>
      {products?.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
};
```

### Local Storage Hook
```javascript
const useLocalStorage = (key, initialValue) => {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = (value) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  };

  return [storedValue, setValue];
};
```

## 4. Performance Optimization

### Memoization with React.memo
```javascript
// ✅ Good: Memoize expensive components
const ProductCard = React.memo(({ product, onAddToCart }) => {
  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>{product.price}</p>
      <button onClick={() => onAddToCart(product)}>
        Add to Cart
      </button>
    </div>
  );
}, (prevProps, nextProps) => {
  // Custom comparison function (optional)
  return prevProps.product.id === nextProps.product.id &&
         prevProps.product.price === nextProps.product.price;
});
```

### useMemo and useCallback
```javascript
const ProductList = ({ products, category, onProductClick }) => {
  // Memoize expensive calculations
  const filteredProducts = useMemo(() => {
    return products.filter(product => 
      category === 'all' || product.category === category
    );
  }, [products, category]);

  // Memoize callback functions
  const handleProductClick = useCallback((product) => {
    onProductClick(product);
    // Analytics tracking
    analytics.track('product_clicked', { productId: product.id });
  }, [onProductClick]);

  return (
    <div>
      {filteredProducts.map(product => (
        <ProductCard 
          key={product.id}
          product={product}
          onClick={handleProductClick}
        />
      ))}
    </div>
  );
};
```

### Code Splitting with React.lazy
```javascript
// Lazy load components for better performance
const ProductDetails = React.lazy(() => import('./ProductDetails'));
const UserDashboard = React.lazy(() => import('./UserDashboard'));

const App = () => {
  return (
    <Router>
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          <Route path="/product/:id" element={<ProductDetails />} />
          <Route path="/dashboard" element={<UserDashboard />} />
        </Routes>
      </Suspense>
    </Router>
  );
};
```

## 5. Error Handling and Boundaries

### Error Boundary Component
```javascript
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Log to error reporting service
    errorReportingService.log(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <p>We're sorry for the inconvenience. Please try refreshing the page.</p>
          <button onClick={() => window.location.reload()}>
            Refresh Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
const App = () => {
  return (
    <ErrorBoundary>
      <Router>
        <Routes>
          {/* Your routes */}
        </Routes>
      </Router>
    </ErrorBoundary>
  );
};
```

## 6. Testing Best Practices

### Component Testing with React Testing Library
```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ProductForm from './ProductForm';

describe('ProductForm', () => {
  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    mockOnSubmit.mockClear();
  });

  test('renders form fields correctly', () => {
    render(<ProductForm onSubmit={mockOnSubmit} />);
    
    expect(screen.getByLabelText(/product name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/price/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /submit/i })).toBeInTheDocument();
  });

  test('submits form with correct data', async () => {
    const user = userEvent.setup();
    render(<ProductForm onSubmit={mockOnSubmit} />);

    await user.type(screen.getByLabelText(/product name/i), 'Test Product');
    await user.type(screen.getByLabelText(/price/i), '99.99');
    await user.click(screen.getByRole('button', { name: /submit/i }));

    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        name: 'Test Product',
        price: '99.99'
      });
    });
  });
});
```

## 7. Accessibility Best Practices

### Semantic HTML and ARIA
```javascript
const Modal = ({ isOpen, onClose, title, children }) => {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      // Focus management
      document.getElementById('modal-close-button').focus();
    } else {
      document.body.style.overflow = 'unset';
    }

    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div 
      className="modal-overlay" 
      onClick={onClose}
      role="dialog"
      aria-labelledby="modal-title"
      aria-modal="true"
    >
      <div 
        className="modal-content" 
        onClick={e => e.stopPropagation()}
      >
        <div className="modal-header">
          <h2 id="modal-title">{title}</h2>
          <button
            id="modal-close-button"
            onClick={onClose}
            aria-label="Close modal"
          >
            ×
          </button>
        </div>
        <div className="modal-body">
          {children}
        </div>
      </div>
    </div>
  );
};
```

## 8. Environment and Build Configuration

### Environment Variables
```javascript
// .env.development
REACT_APP_API_URL=http://localhost:3001/api
REACT_APP_ENVIRONMENT=development

// .env.production
REACT_APP_API_URL=https://api.production.com
REACT_APP_ENVIRONMENT=production

// Using in code
const API_BASE_URL = process.env.REACT_APP_API_URL;
const isDevelopment = process.env.REACT_APP_ENVIRONMENT === 'development';
```

## Key Takeaways

1. **Keep components small and focused** - Single responsibility principle
2. **Use custom hooks** for reusable stateful logic
3. **Optimize performance** with memoization and code splitting
4. **Handle errors gracefully** with error boundaries
5. **Write tests** for critical functionality
6. **Consider accessibility** from the beginning
7. **Use TypeScript** for better developer experience and fewer bugs

## Common Mistakes to Avoid

- Using `useEffect` unnecessarily
- Not cleaning up event listeners and subscriptions
- Mutating state directly
- Over-using global state management
- Ignoring console warnings
- Not implementing proper error handling

These practices have significantly improved the quality and maintainability of my React applications. The key is to be consistent and always consider the long-term impact of your architectural decisions.

What React best practices have you found most valuable in your projects? I'd love to hear about your experiences!